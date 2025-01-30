import 'package:flutter/material.dart';
import 'package:task1/services/task_service.dart';

import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final TaskService taskService;

  TaskProvider({required this.taskService});

  List<Task> _tasks = [];

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
    taskService.addTask(task);
    fetchTasks();
  }

  void deleteTask(int taskId) {
    taskService.deleteTask(taskId);
    fetchTasks();
  }

  void syncTasks() async {
    await taskService.syncTasksWithFirestore();
  }
}
