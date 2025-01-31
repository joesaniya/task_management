import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task1/models/task.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/sreens/add_task_screen.dart';
import 'package:iconsax/iconsax.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final TaskProvider taskProvider;

  TaskTile({required this.task, required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yMMMd').format(task.endDate);
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: task.endDate.isBefore(DateTime.now())
              ? Colors.red.shade100
              : null,
          border: Border.all(
              width: 1,
              color: task.endDate.isBefore(DateTime.now())
                  ? Colors.red
                  : Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.title,
                style: GoogleFonts.metrophobic(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5),
                ),
              ),
              Container(
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTaskScreen(task: task),
                            ),
                          );
                        },
                        child: Icon(Iconsax.edit)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.02,
                    ),
                    InkWell(
                        onTap: () {
                          taskProvider.deleteTask(task.id);
                        },
                        child: Icon(Icons.delete))
                  ],
                ),
              )
            ],
          ),
          Text(
            task.title,
            style: GoogleFonts.metrophobic(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  letterSpacing: .5),
            ),
          ),
          Text(
            'Description: ${task.description}',
            style: GoogleFonts.metrophobic(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  letterSpacing: .5),
            ),
          ),
          Text(
            'Priority: ${task.priority}',
            style: GoogleFonts.metrophobic(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  letterSpacing: .5),
            ),
          ),
          Text(
            'Date: ${formattedDate}',
            style: GoogleFonts.metrophobic(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  letterSpacing: .5),
            ),
          )
        ],
      ),
    );
  }
}
