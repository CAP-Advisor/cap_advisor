import 'display_feedback_model.dart';

class AssigningFeedbackModel {
  final String studentName;
  final String major;
  final String additionalInfo;
  final String uid;

  AssigningFeedbackModel({
    required this.studentName,
    required this.major,
    required this.additionalInfo,
    required this.uid,
  });
  FeedbackModel toFeedbackModel() {
    return FeedbackModel(
      studentId: this.uid,
      studentName: this.studentName,
    );
  }

}
