import 'package:flutter/material.dart';

class InstructorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instructor View'),
      ),
      body: Center(
        child: Text(
          'Instructor View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
