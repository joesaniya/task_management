import 'package:objectbox/objectbox.dart';

@Entity()
class Task {
  int id;
  String title;
  String description;
  String priority;
  String status;
  DateTime endDate;

  Task({
    this.id = 0,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      status: map['status'],
      endDate: DateTime.parse(map['endDate']),
    );
  }
}
