import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objectbox/objectbox.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class TaskService {
  final Store store;
  final FirebaseFirestore firestore;

  TaskService(this.store, this.firestore);

  Future<void> addTask(Task task) async {
    final box = store.box<Task>();
    task.lastUpdated = DateTime.now();
    await box.put(task);
  }

  Future<void> updateTask(Task task) async {
    final box = store.box<Task>();
    task.lastUpdated = DateTime.now();
    await box.put(task);
  }

  Future<void> deleteTask(int taskId) async {
    final box = store.box<Task>();
    await box.remove(taskId);
  }

  List<Task> getTasks() {
    final box = store.box<Task>();
    return box.getAll();
  }

  Future<void> syncTasksWithFirestore() async {
    log('calling syncTasksWithFirestore');
    final box = store.box<Task>();
    final tasks = box.getAll();
    for (var task in tasks) {
      log('task:$task');
      if (task.id == 0) {
        final docRef = await firestore.collection('tasks').add({
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'status': task.status,
          'endDate': task.endDate.toIso8601String(),
          'lastUpdated': task.lastUpdated.toIso8601String(),
        });
        task.id = int.parse(docRef.id);
        await box.put(task);
      } else {
        final docRef = firestore.collection('tasks').doc(task.id.toString());
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'title': task.title,
            'description': task.description,
            'priority': task.priority,
            'status': task.status,
            'endDate': task.endDate.toIso8601String(),
            'lastUpdated': task.lastUpdated.toIso8601String(),
          });
        } else {
          final data = doc.data()!;
          final task = Task(
            id: int.parse(doc.id),
            title: data['title'],
            description: data['description'],
            priority: data['priority'],
            status: data['status'],
            endDate: DateTime.parse(data['endDate']),
            lastUpdated: DateTime.parse(data['lastUpdated']),
          );
          await box.put(task);
        }
      }
    }
    /*  for (var task in tasks) {
      if (task.status == 'Completed') {
        await firestore.collection('tasks').doc(task.id.toString()).set({
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'status': task.status,
          'endDate': task.endDate.toIso8601String(),
          'lastUpdated': task.lastUpdated.toIso8601String(),
        });
      }
    }
 */
  }

  Future<void> exportToSQLite() async {
    final box = store.box<Task>();
    final tasks = box.getAll();
    final databasePath = await getDatabasesPath();
    final db = await openDatabase('$databasePath/tasks.db', version: 1,
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, description TEXT, priority TEXT, status TEXT, endDate TEXT, lastUpdated TEXT)');
    });

    for (var task in tasks) {
      await db.insert('tasks', {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'priority': task.priority,
        'status': task.status,
        'endDate': task.endDate.toIso8601String(),
        'lastUpdated': task.lastUpdated.toIso8601String(),
      });
    }
    await db.close();
  }

  Future<void> importFromSQLite() async {
    final databasePath = await getDatabasesPath();
    final db = await openDatabase('$databasePath/tasks.db');
    final List<Map<String, dynamic>> tasksData = await db.query('tasks');
    await db.close();

    final box = store.box<Task>();
    for (var data in tasksData) {
      final task = Task(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        priority: data['priority'],
        status: data['status'],
        endDate: DateTime.parse(data['endDate']),
        lastUpdated: DateTime.parse(data['lastUpdated']),
      );
      await box.put(task);
    }
  }
}
