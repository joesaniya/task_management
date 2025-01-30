import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objectbox/objectbox.dart';
import '../models/task.dart';

class TaskService {
  final Store store;
  final FirebaseFirestore firestore;

  TaskService(this.store, this.firestore);

  Future<void> addTask(Task task) async {
    final box = store.box<Task>();
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
    final box = store.box<Task>();
    final tasks = box.getAll();

    for (var task in tasks) {
      if (task.status == 'Completed') {
        await firestore.collection('tasks').doc(task.id.toString()).set({
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'status': task.status,
          'endDate': task.endDate.toIso8601String(),
        });
      }
    }
  }
}
