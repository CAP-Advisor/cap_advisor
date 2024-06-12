import 'display_feedback_model.dart';

class AssigningFeedbackModel {
  final String studentName;
  final String major;
  final String additionalInfo;
  final String uid;
  final String? photoUrl;

  AssigningFeedbackModel({
    required this.studentName,
    required this.major,
    required this.additionalInfo,
    required this.uid,
    this.photoUrl,
  });
  FeedbackModel toFeedbackModel() {
    return FeedbackModel(
      studentId: this.uid,
      studentName: this.studentName,
    );
  }

}
