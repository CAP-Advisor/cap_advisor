import 'package:flutter/material.dart';

//for testing(to change)
class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Text(
          'Login Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
