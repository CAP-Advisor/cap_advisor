import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/assigning_feedback_model.dart';
import '../model/student_model.dart';
import '../service/firebase_service.dart';

class AssigningFeedbackViewModel extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  List<AssigningFeedbackModel> feedbacks = [];
  List<AssigningFeedbackModel> filteredFeedbacks = [];

  AssigningFeedbackViewModel() {
    _fetchFeedbackData();
  }

  Future<void> _fetchFeedbackData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String supervisorId = user!.uid;
    List<Student> students =
        await FirebaseService().fetchStudents(supervisorId);
    feedbacks = students
        .map((student) => AssigningFeedbackModel(
              studentName: student.name,
              major: student.major,
              additionalInfo: student.additionalInfo,
              uid: student.uid,
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
