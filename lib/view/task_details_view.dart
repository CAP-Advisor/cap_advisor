import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_appbar.dart';

class TaskDetailsView extends StatelessWidget {
  final Map<String, dynamic> taskData;

  const TaskDetailsView({Key? key, required this.taskData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDeadline = DateFormat('MMMM dd, yyyy').format(taskData['deadline'].toDate());
    Color iconColor = Color(0xFF164863);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Task Details',
        onNotificationPressed: () {
          // Add functionality for notification pressed
        },
        onMenuPressed: () {
          Navigator.of(context).pushNamed('/menu');
        },
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.title, color: iconColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              taskData['Task Title'] ?? "",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: iconColor),
                          SizedBox(width: 8),
                          Text(
                            "Deadline: $formattedDeadline",
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[700]
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Description Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: iconColor),
                          SizedBox(width: 8),
                          Text(
                            "Description",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        taskData['Task Description'] ?? "",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              if (taskData['Task Feedback'] != null && taskData['Task Feedback'].isNotEmpty)
                SizedBox(height: 16),
              // Feedback Card
              if (taskData['Task Feedback'] != null && taskData['Task Feedback'].isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.feedback, color: iconColor),
                            SizedBox(width: 8),
                            Text(
                              "Feedback",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          taskData['Task Feedback'] ?? "",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16),
              // Close Button
            ],
          ),
        ),
      ),
    );
  }
}
