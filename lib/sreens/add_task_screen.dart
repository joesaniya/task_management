import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/provider/task_provider.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priorityController = TextEditingController();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priorityController.text = widget.task!.priority;
      _endDate = widget.task!.endDate;
    }
  }

  void _saveTask() {
    final newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priorityController.text,
      status: widget.task != null ? widget.task!.status : 'Pending',
      endDate: _endDate,
    );

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (widget.task != null) {
      taskProvider.updateTask(newTask); // Update existing task
    } else {
      taskProvider.addTask(newTask); // Add new task
    }

    Navigator.pop(context); // Go back to task list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description'),
            ),
            TextField(
              controller: _priorityController,
              decoration: InputDecoration(labelText: 'Priority (High/Medium/Low)'),
            ),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(widget.task != null ? 'Update Task' : 'Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
