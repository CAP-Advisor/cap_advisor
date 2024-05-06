import 'package:flutter/material.dart';

class HRView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HR View'),
      ),
      body: Center(
        child: Text(
          'HR View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
