import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task1/models/task.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/sreens/task_tile.dart';
import 'add_task_screen.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    log('Connectivity changed: $_connectionStatus');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          taskProvider.fetchTasks();
        });

        List<Task> overdueTasks = taskProvider.tasks
            .where((task) =>
                task.endDate.isBefore(DateTime.now()) &&
                task.status != 'Completed')
            .toList();

        List<Task> lowPriorityTasks = taskProvider.tasks
            .where((task) =>
                task.priority == 'Low' && !overdueTasks.contains(task))
            .toList();
        List<Task> mediumPriorityTasks = taskProvider.tasks
            .where((task) =>
                task.priority == 'Medium' && !overdueTasks.contains(task))
            .toList();
        List<Task> highPriorityTasks = taskProvider.tasks
            .where((task) =>
                task.priority == 'High' && !overdueTasks.contains(task))
            .toList();

        double totalTasks = taskProvider.tasks.length.toDouble();
        if (totalTasks == 0) {
          return Container();
        }

        double completedTasksPercentage = taskProvider.tasks
                .where((task) => task.status == 'Completed')
                .length /
            totalTasks;

        double overdueTasksPercentage = overdueTasks.length / totalTasks * 100;
        double lowPriorityPercentage =
            lowPriorityTasks.length / totalTasks * 100;
        double mediumPriorityPercentage =
            mediumPriorityTasks.length / totalTasks * 100;
        double highPriorityPercentage =
            highPriorityTasks.length / totalTasks * 100;

        double overdueWaveHeight = overdueTasksPercentage / 100;
        double lowPriorityWaveHeight = lowPriorityPercentage / 100;
        double mediumPriorityWaveHeight = mediumPriorityPercentage / 100;
        double highPriorityWaveHeight = highPriorityPercentage / 100;

        return Scaffold(
          appBar: AppBar(
            title: Text('Task List'),
            actions: [
              IconButton(
                onPressed: () {
                  log('Export data Calling');
                  taskProvider.exportTasks();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Tasks Exported")));
                },
                icon: Icon(Icons.file_upload),
                tooltip: 'Export Tasks',
              ),
              IconButton(
                onPressed: () async {
                  log('import data Calling');
                  await taskProvider.importTasks();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Tasks Imported")));
                },
                icon: Icon(Icons.file_download),
                tooltip: 'Import Tasks',
              ),
              IconButton(
                  onPressed: () {
                    taskProvider.syncTasks();
                  },
                  icon: Icon(Icons.cloud))
            ],
          ),
          body: Column(
            children: [
              WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [
                      Colors.red,
                      Colors.red.shade900
                    ], // Overdue tasks - red wave
                    [
                      Colors.green,
                      Colors.green.shade900
                    ], // Low priority tasks - green wave
                    [
                      Colors.blue,
                      Colors.blue.shade900
                    ], // Medium priority tasks - blue wave
                    [
                      Colors.orange,
                      Colors.orange.shade900
                    ], // High priority tasks - orange wave
                  ],
                  durations: [5000, 10000, 15000, 20000],
                  heightPercentages: [
                    overdueWaveHeight.isNaN ? 0.0 : overdueWaveHeight,
                    lowPriorityWaveHeight.isNaN ? 0.0 : lowPriorityWaveHeight,
                    mediumPriorityWaveHeight.isNaN
                        ? 0.0
                        : mediumPriorityWaveHeight,
                    highPriorityWaveHeight.isNaN ? 0.0 : highPriorityWaveHeight,
                  ],
                ),
                size: Size(double.infinity, 200),
                waveAmplitude: 0,
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (overdueTasks.isNotEmpty) ...[
                      ListTile(
                        title: Text(
                            'Overdue Tasks (${overdueTasks.length} - ${overdueTasksPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                      ...overdueTasks
                          .map((task) =>
                              TaskTile(task: task, taskProvider: taskProvider))
                          .toList(),
                    ],
                    if (lowPriorityTasks.isNotEmpty) ...[
                      ListTile(
                        title: Text(
                            'Low Priority Tasks (${lowPriorityTasks.length} - ${lowPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...lowPriorityTasks
                          .map((task) =>
                              TaskTile(task: task, taskProvider: taskProvider))
                          .toList(),
                    ],
                    if (mediumPriorityTasks.isNotEmpty) ...[
                      ListTile(
                        title: Text(
                            'Medium Priority Tasks (${mediumPriorityTasks.length} - ${mediumPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...mediumPriorityTasks
                          .map((task) =>
                              TaskTile(task: task, taskProvider: taskProvider))
                          .toList(),
                    ],
                    if (highPriorityTasks.isNotEmpty) ...[
                      ListTile(
                        title: Text(
                            'High Priority Tasks (${highPriorityTasks.length} - ${highPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...highPriorityTasks
                          .map((task) =>
                              TaskTile(task: task, taskProvider: taskProvider))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(),
                ),
              );
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
