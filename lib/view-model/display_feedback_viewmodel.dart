import 'package:cap_advisor/resources/colors.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/custom_exception.dart';
import '../model/display_feedback_model.dart';
import 'package:http/http.dart' as http;
import '../service/supervisor_firebase_service.dart';

class DisplayFeedbackViewModel extends ChangeNotifier {
  final FeedbackModel feedback;
  String? selectedTaskTitle;
  List<String> dropdownItemList = ["Task Feedback", "Final Feedback"];
  String? selectedFeedbackType;
  String feedbackText = "Feedback";
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> taskTitles = [];
  Map<String, String> titleDescriptionMap = {};

  TextEditingController nameController = TextEditingController();
  TextEditingController taskFeedbackController = TextEditingController();
  TextEditingController finalFeedbackController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();
  TextEditingController taskTitleController = TextEditingController();

  String? selectedTraining;

  DisplayFeedbackViewModel(this.feedback) {
    fetchTaskTitles();
    nameController = TextEditingController(text: feedback.studentName);
  }

  Future<void> fetchTaskTitles() async {
    try {
      DocumentReference studentRef = FirebaseFirestore.instance
          .collection('Student')
          .doc(feedback.studentId);

      QuerySnapshot taskSnapshot = await studentRef.collection('Task').get();

      List<String> titles = [];
      Map<String, String> titleDescriptionMap = {};
      taskSnapshot.docs.forEach((doc) {
        String title = doc['Task Title'];
        titles.add(title);
        titleDescriptionMap[title] = doc['Task Description'];
      });

      taskTitles = titles;
      this.titleDescriptionMap = titleDescriptionMap;

      notifyListeners();
    } catch (error) {
      throw CustomException("Error fetching task titles: $error");
    }
  }

  Future<void> submitFeedback(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (selectedFeedbackType == null ||
          (selectedFeedbackType == "Task Feedback" &&
              (selectedTaskTitle == null ||
                  taskFeedbackController.text.isEmpty)) ||
          (selectedFeedbackType == "Final Feedback" &&
              (finalFeedbackController.text.isEmpty ||
                  selectedTraining == null))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      try {
        String feedbackTypeCollection =
            selectedFeedbackType == 'Task Feedback' ? 'Task' : 'Training';
        if (selectedFeedbackType == 'Task Feedback') {
          String taskId = await getTaskId(selectedTaskTitle!);
          feedbackTypeCollection = 'Task';
          await updateFeedback(
            studentId: feedback.studentId,
            feedbackType: feedbackTypeCollection,
            feedbackId: taskId,
            feedbackData: {
              'Task Feedback': taskFeedbackController.text,
            },
          );
        } else if (selectedFeedbackType == 'Final Feedback') {
          String finalFeedbackText = finalFeedbackController.text;
          await SupervisorFirebaseService().addFeedback(
            studentId: feedback.studentId,
            feedbackType: feedbackTypeCollection,
            feedbackData: {
              'Final Feedback': finalFeedbackText,
              'Training Course': selectedTraining,
            },
          );
          taskTitleController.clear();
          taskDescriptionController.clear();
          taskFeedbackController.clear();

          final url = Uri.parse(
              'https://pacific-chamber-78827-0f1d28754b89.herokuapp.com/send-notification');
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': feedback.studentId,
              'title': 'Feedback Submitted',
              'message': 'Your feedback has been submitted successfully.',
            }),
          );
          if (response.statusCode != 200) {
            throw CustomException('Failed to send notification');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback Added Successfully'),
            backgroundColor: successColor,
          ),
        );
      } catch (error) {
        if (error is CustomException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: errorColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding feedback: $error'),
              backgroundColor: errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> updateFeedback({
    required String studentId,
    required String feedbackType,
    required String feedbackId,
    required Map<String, dynamic> feedbackData,
  }) async {
    try {
      DocumentReference studentRef =
          FirebaseFirestore.instance.collection('Student').doc(studentId);
      DocumentReference feedbackDocRef =
          studentRef.collection(feedbackType).doc(feedbackId);
      await feedbackDocRef.update(feedbackData);

      final url = Uri.parse(
          'https://pacific-chamber-78827-0f1d28754b89.herokuapp.com/send-notification');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': studentId,
          'title': 'Feedback Updated',
          'message': 'Your feedback has been updated successfully.',
        }),
      );
      if (response.statusCode != 200) {
        throw CustomException('Failed to send notification');
      }

      print('Feedback updated successfully');
    } catch (error) {
      throw CustomException("Error updating feedback: $error");
    }
  }

  Future<String> getTaskId(String taskTitle) async {
    try {
      DocumentReference studentRef = FirebaseFirestore.instance
          .collection('Student')
          .doc(feedback.studentId);

      QuerySnapshot taskSnapshot = await studentRef
          .collection('Task')
          .where('Task Title', isEqualTo: taskTitle)
          .get();

      if (taskSnapshot.docs.isNotEmpty) {
        return taskSnapshot.docs.first.id;
      } else {
        throw CustomException('Task ID not found');
      }
    } catch (error) {
      throw CustomException("Error fetching task ID: $error");
    }
  }

  void updateSelectedFeedbackType(String? newValue) {
    selectedFeedbackType = newValue;
    feedbackText =
        newValue == "Task Feedback" ? "Task Feedback" : "Final Feedback";
    selectedTraining = null;
    notifyListeners();
  }
}
