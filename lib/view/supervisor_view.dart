import 'package:flutter/material.dart';

class SupervisorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supervisor View'),
      ),
      body: Center(
        child: Text(
          'Supervisor View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
