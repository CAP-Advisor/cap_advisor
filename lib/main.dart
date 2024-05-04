import 'package:cap_advisor/view/home_view.dart';
import 'package:cap_advisor/view/login_view.dart';
import 'package:cap_advisor/view/sign_up_view.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAP Advisor',
      theme: ThemeData(
      ),
      home: HomeView(),
      routes: {
        '/login': (context) => LoginView(),
        '/SignUp': (context) => SignUpView(),
      },
    );
  }
}
