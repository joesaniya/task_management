import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/models/task.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/sreens/task_tile.dart';
import 'add_task_screen.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class TaskListScreen extends StatelessWidget {
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
        List<Task> pendingTasks = taskProvider.tasks
            .where((task) => !overdueTasks.contains(task))
            .toList();
        double completedTasksPercentage = 0.0;
        if (taskProvider.tasks.isNotEmpty) {
          completedTasksPercentage = taskProvider.tasks
                  .where((task) => task.status == 'Completed')
                  .length /
              taskProvider.tasks.length;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Task List'),
            actions: [
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
                    [Colors.green, Colors.green.shade900],
                    [Colors.blue, Colors.blue.shade900],
                    [Colors.red, Colors.red.shade900],
                  ],
                  durations: [5000, 10000, 15000],
                  heightPercentages: [
                    0.1 + completedTasksPercentage * 0.9,
                    0.2 + completedTasksPercentage * 0.8,
                    0.3 + completedTasksPercentage * 0.7
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
                          title: Text('Overdue Tasks',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold))),
                      ...overdueTasks
                          .map((task) =>
                              TaskTile(task: task, taskProvider: taskProvider))
                          .toList(),
                    ],
                    if (pendingTasks.isNotEmpty) ...[
                      ListTile(
                          title: Text('Pending Tasks',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      ...pendingTasks
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
