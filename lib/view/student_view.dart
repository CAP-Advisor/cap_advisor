import 'package:flutter/material.dart';

class StudentView extends StatelessWidget {
  final String uid;

  const StudentView({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student View'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Student View'),
            SizedBox(height: 20),
            Text('User ID: $uid'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add any functionality specific to Student View here
              },
              child: Text('Student Action'),
            ),
          ],
        ),
      ),
    );
  }
}
