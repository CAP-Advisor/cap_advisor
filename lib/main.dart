import 'package:cap_advisor/view/HR_view.dart';
import 'package:cap_advisor/view/home_view.dart';
import 'package:cap_advisor/view/instructor_view.dart';
import 'package:cap_advisor/view/login_view.dart';
import 'package:cap_advisor/view/sign_up_view.dart';
import 'package:cap_advisor/view/student_view.dart';
import 'package:cap_advisor/view/supervisor_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAQYRsFz0D1RzD693QMsmkzA645-pSQ1_c",
        authDomain: "cap-advisor-a1c2.firebaseapp.com",
        projectId: "cap-advisor-a1c2d",
        storageBucket: "cap-advisor-a1c2d.appspot.com",
        messagingSenderId: "1076600979829",
        appId: "1:1076600979829:android:eaa83474f8326c47b2933c",
      ),
    );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
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
        '/HR':(context) => HRView(),
        '/Supervisor':(context) => SupervisorView(),
        '/Instructor':(context) => InstructorView(),
        '/Student':(context) => StudentView(),
      },
    );
  }
}
