import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/firebase_service.dart';

class StudentViewModel with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? studentData;
  final String uid;

  StudentViewModel({required this.uid});

   Future<void> getStudentData() async {
     String? userId = FirebaseAuth.instance.currentUser?.uid;
     studentData = await _firebaseService.fetchStudentData(userId);
     notifyListeners();
   }
}
