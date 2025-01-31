import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void addTaskk(Task task) {
    taskService.addTask(task);
    fetchTasks();
    syncTasks();
  }

  void addTask(Task task) async {
    task.lastUpdated = DateTime.now();
    taskService.addTask(task);

    if (connectionStatus.contains(ConnectivityResult.mobile) ||
        connectionStatus.contains(ConnectivityResult.wifi)) {
      syncTasks();
    }

    fetchTasks();
  }

  void updateTask(Task task) {
    taskService.updateTask(task);
    fetchTasks();
    syncTasks();
  }

  void deleteTask(int taskId) {
    taskService.deleteTask(taskId);
    fetchTasks();
  }

  Future<void> syncTasks() async {
    if (connectionStatus.contains(ConnectivityResult.mobile) ||
        connectionStatus.contains(ConnectivityResult.wifi)) {
      await taskService.syncTasksWithFirestore();
    }
  }

  void syncTaskss() async {
    await taskService.syncTasksWithFirestore();
  }

  Future<void> exportTasks() async {
    await taskService.exportToSQLite();
  }

  Future<void> importTasks() async {
    await taskService.importFromSQLite();
    fetchTasks();
  }

  void updateTaskStatus(int taskId, String newStatus) {
    Task task = _tasks.firstWhere((task) => task.id == taskId);
    task.status = newStatus;
    task.lastUpdated = DateTime.now();
    taskService.updateTask(task);
    syncTasks();
    notifyListeners();
  }

  //
  List<ConnectivityResult> connectionStatus = [ConnectivityResult.none];
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedPriority = 'All';
  String selectedStatus = 'All';
  Timer? debounce;

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;

    try {
      result = await connectivity.checkConnectivity();
      // log('result:$result');
    } on PlatformException catch (e) {
      // log('Couldn\'t check connectivity status', error: e);
      return;
    }

    return updateConnectionStatus(result);
  }

  Future<void> updateConnectionStatus(List<ConnectivityResult> result) async {
    connectionStatus = result;

    // log('Connectivity changed: $connectionStatus');
    notifyListeners();
  }

  void onSearchChanged() {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery = searchController.text.trim().toLowerCase();
      Calculation();
    });
    notifyListeners();
  }

  List<Task> filteredTasks = [];
  bool matchesSearch = false;
  bool matchesPriority = false;
  bool matchesStatus = false;
  double overdueTasksPercentage = 0.0;
  double completedTasksPercentage = 0.0;
  double totalTasks = 0.0;
  double lowPriorityPercentage = 0.0;
  double mediumPriorityPercentage = 0.0;
  double highPriorityPercentage = 0.0;
  double overdueWaveHeight = 0.0;
  double lowPriorityWaveHeight = 0.0;
  double mediumPriorityWaveHeight = 0.0;
  double highPriorityWaveHeight = 0.0;
  List<Task> overdueTasks = [];
  List<Task> lowPriorityTasks = [];
  List<Task> mediumPriorityTasks = [];
  List<Task> highPriorityTasks = [];

  void Calculation() {
    filteredTasks = tasks.where((task) {
      // matchesSearch = task.title.contains(searchQuery);
      matchesSearch = task.title.contains(searchQuery) ||
          task.description.contains(searchQuery);

      matchesPriority =
          (selectedPriority == 'All' || task.priority == selectedPriority);

      matchesStatus =
          (selectedStatus == 'All' || task.status == selectedStatus);

      return matchesSearch && matchesPriority && matchesStatus;
    }).toList();

    overdueTasks = filteredTasks
        .where((task) =>
            task.endDate.isBefore(DateTime.now()) && task.status != 'Completed')
        .toList();

    lowPriorityTasks = filteredTasks
        .where((task) => task.priority == 'Low' && !overdueTasks.contains(task))
        .toList();
    mediumPriorityTasks = filteredTasks
        .where(
            (task) => task.priority == 'Medium' && !overdueTasks.contains(task))
        .toList();
    highPriorityTasks = filteredTasks
        .where(
            (task) => task.priority == 'High' && !overdueTasks.contains(task))
        .toList();
    notifyListeners();
    totalTasks = filteredTasks.length.toDouble();
    if (totalTasks == 0) {
      return;
    }

    completedTasksPercentage =
        filteredTasks.where((task) => task.status == 'Completed').length /
            totalTasks;

    overdueTasksPercentage = overdueTasks.length / totalTasks * 100;
    lowPriorityPercentage = lowPriorityTasks.length / totalTasks * 100;
    mediumPriorityPercentage = mediumPriorityTasks.length / totalTasks * 100;
    highPriorityPercentage = highPriorityTasks.length / totalTasks * 100;

    overdueWaveHeight = overdueTasksPercentage / 100;
    lowPriorityWaveHeight = lowPriorityPercentage / 100;
    mediumPriorityWaveHeight = mediumPriorityPercentage / 100;
    highPriorityWaveHeight = highPriorityPercentage / 100;
    notifyListeners();
  }

  void setSelectedPriority(String value) {
    selectedPriority = value;
    notifyListeners();
  }
}
