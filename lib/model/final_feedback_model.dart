import 'package:cloud_firestore/cloud_firestore.dart';

class FinalTraining {
  final String course;
  final String feedback;

  FinalTraining({required this.course, required this.feedback});

  factory FinalTraining.fromDocument(DocumentSnapshot doc) {
    return FinalTraining(
      course: doc['Training Course'] ?? '',
      feedback: doc['Final Feedback'] ?? '',
    );
  }
}
