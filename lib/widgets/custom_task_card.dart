import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomTaskCard extends StatelessWidget {
  final Map<String, dynamic> taskData;
  final VoidCallback onPressed;
  final String buttonTitle;

  const CustomTaskCard({
    Key? key,
    required this.taskData,
    required this.onPressed,
    required this.buttonTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFDDF2FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskData['Task Title'] ?? "",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 8),
                Text(
                  "Assigned By: ${taskData['Supervisor Name'] ?? ""}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            _buildTaskDetailsButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0XFF164863),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        buttonTitle,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
