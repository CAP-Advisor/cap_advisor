import 'package:flutter/material.dart';
import '../model/assigning_feedback_model.dart';

class CustomCard extends StatelessWidget {
  final AssigningFeedbackModel feedback;
  final VoidCallback onTap;
  final VoidCallback onAddFeedbackPressed;

  const CustomCard({
    Key? key,
    required this.feedback,
    required this.onTap,
    required this.onAddFeedbackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFDDF2FD),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xFFCFE0E9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.black),
        ),
        title: Text(feedback.studentName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Major: ${feedback.major}"),
            Text(
              "${feedback.additionalInfo}",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onAddFeedbackPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF164863),
          ),
          child: Text(
            "Add Feedback",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
