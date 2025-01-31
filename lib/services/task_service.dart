import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
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

    final docRef = firestore.collection('tasks').doc(task.id.toString());
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'title': task.title,
        'description': task.description,
        'priority': task.priority,
        'status': task.status,
        'endDate': task.endDate?.toIso8601String(),
        'lastUpdated': task.lastUpdated?.toIso8601String(),
      });
    } else {
      await docRef.set({
        'title': task.title,
        'description': task.description,
        'priority': task.priority,
        'status': task.status,
        'endDate': task.endDate?.toIso8601String(),
        'lastUpdated': task.lastUpdated?.toIso8601String(),
      });
    }
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
    log('Calling syncTasksWithFirestore');
    final box = store.box<Task>();
    final tasks = box.getAll();
    log('Tasks in ObjectBox: ${tasks.length}');

    for (var task in tasks) {
      log('Syncing task: ${task.title}');
      if (task.id == 0) {
        final docRef = await firestore.collection('tasks').add({
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'status': task.status,
          'endDate': task.endDate?.toIso8601String(),
          'lastUpdated': task.lastUpdated?.toIso8601String(),
        });
        task.id = int.parse(docRef.id);
        await box.put(task);
        log('New task synced: ${task.title}');
      } else {
      
        final docRef = firestore.collection('tasks').doc(task.id.toString());
        final doc = await docRef.get();

        if (doc.exists) {
          final data = doc.data()!;
          final firestoreTask = Task(
            id: int.parse(doc.id),
            title: data['title'],
            description: data['description'],
            priority: data['priority'],
            status: data['status'],
            endDate: DateTime.parse(data['endDate']),
            lastUpdated: DateTime.parse(data['lastUpdated']),
          );
          await box.put(firestoreTask);
          log('Existing task synced: ${firestoreTask.title}');
        } else {
          await docRef.set({
            'title': task.title,
            'description': task.description,
            'priority': task.priority,
            'status': task.status,
            'endDate': task.endDate?.toIso8601String(),
            'lastUpdated': task.lastUpdated?.toIso8601String(),
          });
          log('Task created in Firestore: ${task.title}');
        }
      }
    }
  }


  Future<void> exportToSQLite() async {
    final box = store.box<Task>();
    final tasks = box.getAll();

    Directory? downloadsDirectory;

    if (Platform.isAndroid) {
      if (Platform.version.contains("11")) {
        downloadsDirectory = await getExternalStorageDirectory();
      } else {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      }

      if (downloadsDirectory != null && !(await downloadsDirectory.exists())) {
        await downloadsDirectory.create(recursive: true);
      }
    } else if (Platform.isIOS) {
      downloadsDirectory = await getDownloadsDirectory();
    }

    if (downloadsDirectory == null || !await downloadsDirectory.exists()) {
      print("Downloads folder not found.");
      return;
    }

    String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final dbPath = '${downloadsDirectory.path}/tasks_$formattedDate.db';

    log('Database Path: $dbPath');

    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        try {
          await db.execute('CREATE TABLE IF NOT EXISTS tasks ('
              'id INTEGER PRIMARY KEY, '
              'title TEXT, '
              'description TEXT, '
              'priority TEXT, '
              'status TEXT, '
              'endDate TEXT, '
              'lastUpdated TEXT)');
          log('Table created successfully.');
        } catch (e) {
          log('Error creating table: $e');
        }
      },
    );

    await db.transaction((txn) async {
      for (var task in tasks) {
        try {
          final existingTask = await txn.query(
            'tasks',
            where: 'id = ?',
            whereArgs: [task.id],
          );

          if (existingTask.isEmpty) {
            await txn.insert('tasks', {
              'id': task.id,
              'title': task.title,
              'description': task.description,
              'priority': task.priority,
              'status': task.status,
              'endDate': task.endDate?.toIso8601String(),
              'lastUpdated': task.lastUpdated?.toIso8601String(),
            });
            log('Task inserted: ${task.title}');
          } else {
            await txn.update(
              'tasks',
              {
                'title': task.title,
                'description': task.description,
                'priority': task.priority,
                'status': task.status,
                'endDate': task.endDate?.toIso8601String(),
                'lastUpdated': task.lastUpdated?.toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [task.id],
            );
            log('Task updated: ${task.title}');
          }
        } catch (e) {
          print('Error processing task: $e');
        }
      }
    });

    await db.close();
    log('Tasks export to SQLite complete. Database saved at $dbPath');
  }

 
  Future<void> importFromSQLite() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) {
      print("No database file selected.");
      return;
    }

    final dbPath = result.files.single.path!;
    print("Importing from: $dbPath");

    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS tasks ( 
          id INTEGER PRIMARY KEY, 
          title TEXT, 
          description TEXT, 
          priority TEXT, 
          status TEXT, 
          endDate TEXT, 
          lastUpdated TEXT 
        ) 
        ''');
      },
    );

    final List<Map<String, dynamic>> tasksData = await db.query('tasks');
    await db.close();

    if (tasksData.isEmpty) {
      print("No tasks found in SQLite.");
      return;
    }

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

    log("Tasks imported successfully from SQLite.");
  }
}
