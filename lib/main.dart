import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/services/task_service.dart';
import 'package:task1/sreens/home_screen.dart';
import 'package:task1/sreens/task_list_screen.dart';

import 'objectbox.g.dart'; // Generated by objectbox

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final store = await openStore();
  final taskService = TaskService(store, FirebaseFirestore.instance);

  runApp(MyApp(taskService: taskService));
}

class MyApp extends StatelessWidget {
  final TaskService taskService;

  MyApp({required this.taskService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(taskService: taskService),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Management App',
        theme: ThemeData(primarySwatch: Colors.blue),
        // home: TaskListScreen(),
        home: HomeScreen(taskService: taskService),
      ),
    );
  }
}
