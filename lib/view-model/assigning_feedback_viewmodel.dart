import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/assigning_feedback_model.dart';
import '../model/student_model.dart';
import '../service/supervisor_firebase_service.dart';

class AssigningFeedbackViewModel extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  List<AssigningFeedbackModel> feedbacks = [];
  List<AssigningFeedbackModel> filteredFeedbacks = [];

  AssigningFeedbackViewModel() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        feedbacks.clear();
        filteredFeedbacks.clear();
      } else {
        _fetchFeedbackData();
      }
    });
  }

  Future<void> _fetchFeedbackData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String supervisorId = user!.uid;
    List<Student> students =
        await SupervisorFirebaseService().fetchStudentsId(supervisorId);
    feedbacks = students
        .map((student) => AssigningFeedbackModel(
              studentName: student.name,
              major: student.major,
              additionalInfo: student.additionalInfo,
              uid: student.uid,
              photoUrl: student.photoUrl,
            ))
        .toList();
    filteredFeedbacks = feedbacks;
    notifyListeners();
  }

  void filterFeedbacks(String query) {
    filteredFeedbacks = feedbacks
        .where((feedback) =>
            feedback.studentName.toLowerCase().contains(query.toLowerCase()) ||
            feedback.major.toLowerCase().contains(query.toLowerCase()) ||
            feedback.additionalInfo.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
