// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Future<void> initializeNotifications() async {
//   final AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('app_icon');
  
//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);
  
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

// void scheduleNotification(Task task) {
//   final notificationDetails = NotificationDetails(
//     android: AndroidNotificationDetails(
//       'task_channel',
//       'Task Notifications',
//       importance: Importance.max,
//     ),
//   );

//   flutterLocalNotificationsPlugin.zonedSchedule(
//     0,
//     'Reminder: ${task.title}',
//     'You have a task deadline approaching!',
//     task.endDate,
//     notificationDetails,
//     androidAllowWhileIdle: true,
//   );
// }
