import 'package:flutter/material.dart';

class AddTaskView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Tasks'),
        backgroundColor: Color(0xFF427D9D),
      ),
      body: Center(child: Text("tasks")),
    );
  }
}
