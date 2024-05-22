import 'package:flutter/material.dart';

class SupervisorView extends StatelessWidget {
  final String uid;

  const SupervisorView({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supervisor View'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Supervisor View'),
            SizedBox(height: 20),
            Text('User ID: $uid'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add any functionality specific to Supervisor View here
              },
              child: Text('Supervisor Action'),
            ),
          ],
        ),
      ),
    );
  }
}
