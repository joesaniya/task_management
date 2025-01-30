import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/provider/task_provider.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        taskProvider.fetchTasks();
        double completedTasksPercentage = 0.0;
        if (taskProvider.tasks.isNotEmpty) {
          completedTasksPercentage = taskProvider.tasks
                  .where((task) => task.status == 'Completed')
                  .length /
              taskProvider.tasks.length;
        }

        return Scaffold(
          appBar: AppBar(title: Text('Task List')),
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
                child: ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    bool isOverdue = task.endDate.isBefore(DateTime.now()) &&
                        task.status != 'Completed';
                    bool isApproachingDeadline = task.endDate
                            .isBefore(DateTime.now().add(Duration(days: 1))) &&
                        task.status != 'Completed';

                    return ListTile(
                      tileColor: isOverdue
                          ? Colors.red.shade100
                          : isApproachingDeadline
                              ? Colors.yellow.shade100
                              : null,
                      title: Text(task.title),
                      subtitle: Text(task.description),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTaskScreen(task: task),
                            ),
                          );
                        },
                      ),
                      onLongPress: () {
                        taskProvider.deleteTask(task.id);
                      },
                    );
                  },
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
