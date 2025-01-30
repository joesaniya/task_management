import 'package:flutter/material.dart';
import 'package:task1/services/task_service.dart';

import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final TaskService taskService;
  List<Task> _tasks = [];

  TaskProvider({required this.taskService});

  List<Task> get tasks => _tasks;

  void fetchTasks() {
    _tasks = taskService.getTasks();
    notifyListeners();
  }

  void addTask(Task task) {
    taskService.addTask(task);
    fetchTasks();
  }

  void updateTask(Task task) {
    taskService.updateTask(task);
    fetchTasks();
  }

  void deleteTask(int taskId) {
    taskService.deleteTask(taskId);
    fetchTasks();
  }

  void syncTasks() async {
    await taskService.syncTasksWithFirestore();
  }

  Future<void> exportTasks() async {
    await taskService.exportToSQLite();
  }

  Future<void> importTasks() async {
    await taskService.importFromSQLite();
    fetchTasks();
  }
}
