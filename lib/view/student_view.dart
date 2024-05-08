import 'package:flutter/material.dart';

class StudentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student View'),
      ),
      body: Center(
        child: Text(
          'Student View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
