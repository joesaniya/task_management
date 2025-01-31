import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:task1/widgets/custom_dropdown-widget.dart';
import 'package:task1/widgets/custom_input_field.dart';
import 'package:task1/widgets/text_widget.dart';
import '../provider/task_provider.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _endDateController = TextEditingController();
  String _priority = 'Medium';
  String _status = 'Pending';
  DateTime _endDate = DateTime.now();
  bool isAnimated = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _endDate = widget.task!.endDate;
      _endDateController.text = _endDate.toLocal().toString().split(' ')[0];
    }

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isAnimated = true;
      });
    });
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
        _endDateController.text = _endDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      log('Date:$_endDate');
      final task = Task(
        id: widget.task?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _priority,
        status: _status,
        endDate: _endDate,
        lastUpdated: DateTime.now(),
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (widget.task != null) {
        taskProvider.updateTask(task);
      } else {
        taskProvider.addTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  AnimatedOpacity(
                    opacity: isAnimated ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: TextWidget(
                      text: widget.task != null ? 'Edit Task' : 'Add Task',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomInputField(
                    label: 'Task Title',
                    hintText: 'Enter your task title',
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                    inputType: TextInputType.text,
                    backgroundColor:
                        Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                  CustomInputField(
                    label: 'Task Description',
                    hintText: 'Enter your task description',
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task description';
                      }
                      return null;
                    },
                    inputType: TextInputType.text,
                    backgroundColor:
                        Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                  AnimatedOpacity(
                    opacity: isAnimated ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: CustomDropdown(
                      value: _priority,
                      title: 'Priority',
                      items: ['High', 'Medium', 'Low'],
                      labelText: 'Priority',
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: isAnimated ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: CustomDropdown(
                      title: 'Status',
                      value: _status,
                      items: ['Pending', 'Completed'],
                      labelText: 'Status',
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                    ),
                  ),
                  /* CustomInputField(
                    label: 'Date',
                    hintText: 'Pick the date',
                    controller: _endDateController,
                    isDatePicker: true,
                    onDateSelected: (date) {
                      log('Date selected: $date');
                      _endDateController.text = date;
                    },
                    backgroundColor:
                        Theme.of(context).inputDecorationTheme.fillColor,
                  ),*/
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  AnimatedOpacity(
                    opacity: isAnimated ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: _pickDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an end date';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        suffixIcon: Icon(Iconsax.calendar),
                        labelStyle: GoogleFonts.metrophobic(
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            letterSpacing: .5,
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.metrophobic(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                      child: Text(
                          widget.task != null ? 'Update Task' : 'Save Task'),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
