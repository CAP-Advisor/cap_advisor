import 'package:cap_advisor/resources/colors.dart';
import 'package:flutter/material.dart';

class CustomPositionCard extends StatelessWidget {
  final String title;
  final String companyName;
  final String description;
  final String positionType;
  final List<String> skills;
  final VoidCallback onPressed;

  const CustomPositionCard({
    required this.title,
    required this.companyName,
    required this.description,
    required this.positionType,
    required this.skills,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 10.0),
                    Text(
                      companyName,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text(
                  positionType,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Title: $title',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Description: $description',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Required Skills:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: skills
                      .map((skill) => Chip(
                            label: Text(
                              skill,
                            ),
                            backgroundColor: cardColor,
                          ))
                      .toList(),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text('Apply', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
