import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/services/task_service.dart';
import 'package:task1/sreens/task_tile.dart';
import 'package:task1/utils/connectivity_status.dart';
import 'package:task1/widgets/custom_snackbar.dart';
import 'package:task1/widgets/wave_widget.dart';
import 'package:task1/widgets/welcome_text_widget.dart';

class HomeScreen extends StatefulWidget {
  final TaskService taskService;
  const HomeScreen({required this.taskService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TaskProvider controller;
  @override
  void initState() {
    super.initState();

    controller = TaskProvider(taskService: widget.taskService);
    controller.initConnectivity();

    controller.connectivitySubscription = controller
        .connectivity.onConnectivityChanged
        .listen(controller.updateConnectionStatus);
    controller.searchController.addListener(controller.onSearchChanged);
  }

  @override
  void dispose() {
    controller.connectivitySubscription.cancel();
    controller.searchController.removeListener(controller.onSearchChanged);
    controller.debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          taskProvider.initConnectivity();
          taskProvider.fetchTasks();
          taskProvider.syncTasks();
          /* taskProvider.connectionStatus.first == ConnectivityResult.none
              ? taskProvider.syncTasks()
              : taskProvider.syncTasks();*/
        });
        taskProvider.Calculation();
        log(' connectivity status:${taskProvider.connectionStatus.first}');
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.menu,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      log('Export data Calling');
                                      taskProvider.exportTasks();
                                      CustomSnackbar.show(
                                        context,
                                        message: "Tasks Exported!",
                                        backgroundColor: Colors.deepPurple,
                                        textColor: Colors.white,
                                        icon: Icons.check_circle,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.file_upload,
                                      color: Colors.deepPurple,
                                    ),
                                    tooltip: 'Export Tasks',
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      log('import data Calling');
                                      await taskProvider.importTasks();

                                      CustomSnackbar.show(
                                        context,
                                        message: "Tasks Imported!",
                                        backgroundColor: Colors.deepPurple,
                                        textColor: Colors.white,
                                        icon: Icons.check_circle,
                                      );
                                    },
                                    icon: Icon(Icons.file_download,
                                        color: Colors.deepPurple),
                                    tooltip: 'Import Tasks',
                                  ),
                                  /*  _connectionStatus.first ==
                                          ConnectivityResult.none
                                      ? SizedBox()
                                      : IconButton(
                                          onPressed: () {
                                            taskProvider.syncTasks();
                                          },
                                          icon: Icon(Icons.cloud,
                                              color: Colors.deepPurple))*/
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  taskProvider.connectionStatus.first == ConnectivityResult.none
                      ? ConnectivityStatus()
                      : SizedBox(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: taskProvider.searchController,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.metrophobic(
                                textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: .5,
                                ),
                              ),
                              // hintText: "search",
                              labelText: 'Search Tasks',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Iconsax.search_normal_1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  /* Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.metrophobic(
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            letterSpacing: .5,
                          ),
                        ),
                        labelText: 'Search Tasks',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                 */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        iconEnabledColor: Colors.deepPurple,
                        value: taskProvider.selectedPriority,
                        style: GoogleFonts.metrophobic(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .5,
                          ),
                        ),
                        onChanged: (value) {
                          taskProvider.setSelectedPriority(value!);
                        },
                        items: ['All', 'Low', 'Medium', 'High']
                            .map((e) => DropdownMenuItem(
                                  child: Text(e),
                                  value: e,
                                ))
                            .toList(),
                      ),
                      DropdownButton<String>(
                        iconEnabledColor: Colors.deepPurple,
                        value: taskProvider.selectedStatus,
                        style: GoogleFonts.metrophobic(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .5,
                          ),
                        ),
                        onChanged: (value) {
                          taskProvider.setSelectedPriority(value!);
                        },
                        items: ['All', 'Pending', 'Completed']
                            .map((e) => DropdownMenuItem(
                                  child: Text(e),
                                  value: e,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  WelcomeTextWidget(),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      WaveContainer(
                        title: "Overdue Tasks",
                        waveHeightPercentage: taskProvider.overdueWaveHeight,
                        completedTasksPercentage:
                            taskProvider.completedTasksPercentage,
                        colors: [Colors.red, Colors.red.shade900],
                        percentage: taskProvider.overdueTasksPercentage,
                      ),
                      WaveContainer(
                        title: "Low Priority",
                        waveHeightPercentage:
                            taskProvider.lowPriorityWaveHeight,
                        completedTasksPercentage:
                            taskProvider.completedTasksPercentage,
                        colors: [Colors.green, Colors.green.shade900],
                        percentage: taskProvider.lowPriorityPercentage,
                      ),
                      WaveContainer(
                        title: "Medium Priority",
                        waveHeightPercentage:
                            taskProvider.mediumPriorityWaveHeight,
                        completedTasksPercentage:
                            taskProvider.completedTasksPercentage,
                        colors: [Colors.blue, Colors.blue.shade900],
                        percentage: taskProvider.mediumPriorityPercentage,
                      ),
                      WaveContainer(
                        title: "High Priority",
                        waveHeightPercentage:
                            taskProvider.highPriorityWaveHeight,
                        completedTasksPercentage:
                            taskProvider.completedTasksPercentage,
                        colors: [Colors.orange, Colors.orange.shade900],
                        percentage: taskProvider.highPriorityPercentage,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Column(
                    children: [
                      if (taskProvider.overdueTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Overdue Tasks (${taskProvider.overdueTasks.length} - ${taskProvider.overdueTasksPercentage.toStringAsFixed(1)}%)',
                            style: GoogleFonts.metrophobic(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                        ),
                        ...taskProvider.overdueTasks
                            .map((task) => TaskTile(
                                task: task, taskProvider: taskProvider))
                            .toList(),
                      ],
                      if (taskProvider.lowPriorityTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Low Priority Tasks (${taskProvider.lowPriorityTasks.length} - ${taskProvider.lowPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        ...taskProvider.lowPriorityTasks
                            .map((task) => TaskTile(
                                task: task, taskProvider: taskProvider))
                            .toList(),
                      ],
                      if (taskProvider.mediumPriorityTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Medium Priority Tasks (${taskProvider.mediumPriorityTasks.length} - ${taskProvider.mediumPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        ...taskProvider.mediumPriorityTasks
                            .map((task) => TaskTile(
                                task: task, taskProvider: taskProvider))
                            .toList(),
                      ],
                      if (taskProvider.highPriorityTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'High Priority Tasks (${taskProvider.highPriorityTasks.length} - ${taskProvider.highPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        ...taskProvider.highPriorityTasks
                            .map((task) => TaskTile(
                                task: task, taskProvider: taskProvider))
                            .toList(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
