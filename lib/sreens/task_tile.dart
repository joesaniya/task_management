import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:task1/models/task.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/sreens/add_task_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final TaskProvider taskProvider;

  TaskTile({required this.task, required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    // Format the end date
    String formattedDate = DateFormat('yMMMd').format(task.endDate);

    return ListTile(
      tileColor:
          task.endDate.isBefore(DateTime.now()) ? Colors.red.shade100 : null,
      title: Text(task.title),
      subtitle: Text(
        '${task.description}\nPriority: ${task.priority}\nDue Date: $formattedDate', // Display the formatted date
        style: TextStyle(fontSize: 14),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          taskProvider.deleteTask(task.id);
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTaskScreen(task: task),
          ),
        );
      },
    );
  }
}
