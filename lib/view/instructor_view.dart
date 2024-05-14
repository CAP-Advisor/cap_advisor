import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_view.dart';

class InstructorView extends StatelessWidget {
  final String uid;
  InstructorView({required this.uid});

  Widget logoutBtn(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginView()));
        },
        child: const Text(
          'Logout', // Changed the text to indicate the action clearly
          style: TextStyle(color: Color(0xFF427D9D)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor View'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 50, // You can adjust the position as needed
              child: const Text(
                'Instructor View',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Positioned(
              bottom: 50, // You can adjust the position as needed
              child: logoutBtn(
                  context), // Correctly reference the method and pass context
            ),
          ],
        ),
      ),
    );
  }
}
