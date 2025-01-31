import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task1/models/task.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/sreens/task_tile.dart';
import 'package:task1/utils/connectivity_status.dart';
import 'package:task1/widgets/wave_widget.dart';
import 'package:task1/widgets/welcome_text_widget.dart';

class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPriority = 'All';
  String _selectedStatus = 'All';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();

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
          _connectionStatus.first == ConnectivityResult.none
              ? taskProvider.syncTasks()
              : null;
        });

        List<Task> filteredTasks = taskProvider.tasks.where((task) {
          bool matchesSearch = task.title.contains(_searchQuery) ||
              task.description.contains(_searchQuery);

          bool matchesPriority = (_selectedPriority == 'All' ||
              task.priority == _selectedPriority);

          bool matchesStatus =
              (_selectedStatus == 'All' || task.status == _selectedStatus);

          return matchesSearch && matchesPriority && matchesStatus;
        }).toList();

        List<Task> overdueTasks = filteredTasks
            .where((task) =>
                task.endDate.isBefore(DateTime.now()) &&
                task.status != 'Completed')
            .toList();

        List<Task> lowPriorityTasks = filteredTasks
            .where((task) =>
                task.priority == 'Low' && !overdueTasks.contains(task))
            .toList();
        List<Task> mediumPriorityTasks = filteredTasks
            .where((task) =>
                task.priority == 'Medium' && !overdueTasks.contains(task))
            .toList();
        List<Task> highPriorityTasks = filteredTasks
            .where((task) =>
                task.priority == 'High' && !overdueTasks.contains(task))
            .toList();

        double totalTasks = filteredTasks.length.toDouble();
        if (totalTasks == 0) {
          return Container();
        }

        double completedTasksPercentage =
            filteredTasks.where((task) => task.status == 'Completed').length /
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("Tasks Exported")));
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("Tasks Imported")));
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
                  _connectionStatus.first == ConnectivityResult.none
                      ? ConnectivityStatus()
                      : SizedBox(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Tasks',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedPriority,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                        items: ['All', 'Low', 'Medium', 'High']
                            .map((e) => DropdownMenuItem(
                                  child: Text(e),
                                  value: e,
                                ))
                            .toList(),
                      ),
                      DropdownButton<String>(
                        value: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
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
                  WelcomeTextWidget(),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      WaveContainer(
                        title: "Overdue Tasks",
                        waveHeightPercentage: overdueWaveHeight,
                        completedTasksPercentage: completedTasksPercentage,
                        colors: [Colors.red, Colors.red.shade900],
                        percentage: overdueTasksPercentage,
                      ),
                      WaveContainer(
                        title: "Low Priority",
                        waveHeightPercentage: lowPriorityWaveHeight,
                        completedTasksPercentage: completedTasksPercentage,
                        colors: [Colors.green, Colors.green.shade900],
                        percentage: lowPriorityPercentage,
                      ),
                      WaveContainer(
                        title: "Medium Priority",
                        waveHeightPercentage: mediumPriorityWaveHeight,
                        completedTasksPercentage: completedTasksPercentage,
                        colors: [Colors.blue, Colors.blue.shade900],
                        percentage: mediumPriorityPercentage,
                      ),
                      WaveContainer(
                        title: "High Priority",
                        waveHeightPercentage: highPriorityWaveHeight,
                        completedTasksPercentage: completedTasksPercentage,
                        colors: [Colors.orange, Colors.orange.shade900],
                        percentage: highPriorityPercentage,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Column(
                    children: [
                      if (overdueTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Overdue Tasks (${overdueTasks.length} - ${overdueTasksPercentage.toStringAsFixed(1)}%)',
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
                        ...overdueTasks
                            .map((task) => TaskTile(
                                task: task, taskProvider: taskProvider))
                            .toList(),
                      ],
                      if (lowPriorityTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Low Priority Tasks (${lowPriorityTasks.length} - ${lowPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        ...lowPriorityTasks
                            .map((task) => TaskTile(
                                task: task, taskProvider: taskProvider))
                            .toList(),
                      ],
                      if (mediumPriorityTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Medium Priority Tasks (${mediumPriorityTasks.length} - ${mediumPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        ...mediumPriorityTasks
                            .map((task) => TaskTile(
                                task: task, taskProvider: taskProvider))
                            .toList(),
                      ],
                      if (highPriorityTasks.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'High Priority Tasks (${highPriorityTasks.length} - ${highPriorityPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        ...highPriorityTasks
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
