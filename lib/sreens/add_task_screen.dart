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
  String _priority = 'Medium';
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
      _endDate = widget.task!.endDate;
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    final task = Task(
      id: widget.task?.id ?? 0,
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority,
      status: widget.task?.status ?? 'Pending',
      endDate: _endDate,
    );
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (widget.task != null) {
      taskProvider.updateTask(task);
    } else {
      taskProvider.addTask(task);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.task != null ? 'Edit Task' : 'Add Task')),
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
            DropdownButtonFormField<String>(
              value: _priority,
              items: ['High', 'Medium', 'Low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Priority'),
            ),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: _pickDate,
              icon: Icon(Icons.calendar_today),
              label: Text('End Date: ${_endDate.toLocal()}'.split(' ')[0]),
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
