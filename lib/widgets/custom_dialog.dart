import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDialog extends StatelessWidget {
  final Map<String, dynamic> taskData;
  final VoidCallback onClose;
  final bool showFeedback;

  const CustomDialog({
    Key? key,
    required this.taskData,
    required this.onClose,
    required this.showFeedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDeadline = DateFormat('MMMM dd, yyyy').format(taskData['deadline'].toDate());

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              taskData['Task Title'] ?? "",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Deadline: $formattedDeadline",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Description:",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              taskData['Task Description'] ?? "",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (showFeedback && taskData['Task Feedback'] != null && taskData['Task Feedback'].isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    "Feedback:",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    taskData['Task Feedback'] ?? "",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), backgroundColor: Color(0xFF164863),
              ),
              child: Text(
                "Close",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}