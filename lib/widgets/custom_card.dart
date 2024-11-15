import 'package:cap_advisor/resources/colors.dart';
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
      color: cardColor,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 24,
          backgroundImage: feedback.photoUrl != null
              ? NetworkImage(feedback.photoUrl!)
              : null,
          child: feedback.photoUrl == null
              ? Text(
            feedback.studentName.isNotEmpty
                ? feedback.studentName[0]
                : '',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          )
              : null,
        ),
        title: Text(feedback.studentName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Major: ${feedback.major}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              "Specialization: ${feedback.additionalInfo}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Tooltip(
          message: 'Add Feedback',
          child: IconButton(
            onPressed: onAddFeedbackPressed,
            icon: Icon(Icons.add_comment,color: secondaryColor,),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
