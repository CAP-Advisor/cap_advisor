import 'dart:js';

import 'package:cap_advisor/view/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HRView extends StatelessWidget {
  Widget logoutBtn(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginView()));
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
        title: const Text('HR View'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 50, // You can adjust the position as needed
              child: const Text(
                'HR View',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Positioned(
              bottom: 50, // You can adjust the position as needed
              child: logoutBtn(context), // Correctly reference the method and pass context
            ),
          ],
        ),
      ),
    );
  }
}
