import 'package:cap_advisor/utils/validation_utils.dart';
import 'package:cap_advisor/view/HR_view.dart';
import 'package:cap_advisor/view/instructor_view.dart';
import 'package:cap_advisor/view/student_view.dart';
import 'package:cap_advisor/view/supervisor_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../service/firebase_service.dart';

class LoginViewModel {
  final FirebaseService _firebaseService = FirebaseService();
  late String userType;

  Future<bool> login(String email, String password) async {
    try {
      // Validate email format
      if (!ValidationUtils.isValidEmail(email)) {
        return false;
      }

      // Authenticate user with Firebase
      User? user = await _firebaseService.signInWithEmailAndPassword(email, password);

      if (user == null) {
        // Authentication failed
        return false;
      }
      Map<String, dynamic>? userData = await _firebaseService.getUserData(email);
      if (userData != null) {
        userType = userData['userType']; // Store user type
          return true;
        } else {
          return false; // Passwords do not match
        }

    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  void redirectUser(BuildContext context, String userType) {
    switch (userType) {
      case 'HR':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HRView()));
        break;
      case 'Supervisor':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SupervisorView()));
        break;
      case 'Instructor':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InstructorView()));
        break;
      case 'Student':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentView()));
        break;
      default:
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unknown user type')),
    );
    }
  }
}
