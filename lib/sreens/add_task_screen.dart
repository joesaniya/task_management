import 'dart:developer';

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
  final _endDateController = TextEditingController();
  String _priority = 'Medium';
  String _status = 'Pending'; // Add status field
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
      _status = widget.task!.status; // Set status from existing task
      _endDate = widget.task!.endDate;
      _endDateController.text = _endDate.toLocal().toString().split(' ')[0];
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _endDate) {
      setState(() {
        _endDate = pickedDate;
        _endDateController.text = _endDate.toLocal().toString().split(' ')[0];
      });
    }
    log('Date:${_endDateController.text}');
  }

  void _saveTask() {
    final task = Task(
        id: widget.task?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _priority,
        status: _status, // Save the selected status
        endDate: _endDate,
        lastUpdated: DateTime.now());
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
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Pending', 'Completed']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Status'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _endDateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: 'End Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
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
