import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/display_feedback_model.dart';
import '../service/firebase_service.dart';

class DisplayFeedbackViewModel extends ChangeNotifier {
  final FeedbackModel feedback;
  String? selectedTaskTitle;
  List<String> dropdownItemList = ["Task Feedback", "Final Feedback"];
  String? selectedFeedbackType;
  String feedbackText = "Feedback";
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Task titles retrieved from Firestore
  List<String> taskTitles = [];
  Map<String, String> titleDescriptionMap = {};

  TextEditingController nameController = TextEditingController();
  TextEditingController taskFeedbackController = TextEditingController();
  TextEditingController finalFeedbackController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();
  TextEditingController taskTitleController = TextEditingController();

  String? selectedTraining;

  DisplayFeedbackViewModel(this.feedback) {
    // Fetch task titles from Firestore on initialization
    fetchTaskTitles();
    nameController = TextEditingController(text: feedback.studentName);
  }

  // Fetch task titles from Firestore
  Future<void> fetchTaskTitles() async {
    try {
      // Get reference to student document
      DocumentReference studentRef = FirebaseFirestore.instance
          .collection('Student')
          .doc(feedback.studentId);

      // Get tasks collection under the student document
      QuerySnapshot taskSnapshot = await studentRef.collection('Task').get();

      // Extract task titles and descriptions from the snapshot
      List<String> titles = [];
      Map<String, String> titleDescriptionMap = {};
      taskSnapshot.docs.forEach((doc) {
        String title = doc['Task Title'];
        titles.add(title);
        titleDescriptionMap[title] = doc['Task Description'];
      });

      // Update taskTitles and titleDescriptionMap with retrieved data
      taskTitles = titles;
      this.titleDescriptionMap = titleDescriptionMap;

      notifyListeners(); // Notify listeners of change
    } catch (error) {
      // Handle error
      print("Error fetching task titles: $error");
    }
  }

  Future<void> submitFeedback(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      // Check if any field or dropdown is empty or null
      if (selectedFeedbackType == null ||
          (selectedFeedbackType == "Task Feedback" &&
              (selectedTaskTitle == null ||
                  taskFeedbackController.text.isEmpty)) ||
          (selectedFeedbackType == "Final Feedback" &&
              (finalFeedbackController.text.isEmpty ||
                  selectedTraining == null))) {
        // Show snackbar if any field or dropdown is empty or null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit early if any field is empty or null
      }

      try {
        // Proceed with feedback submission
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
          await FirebaseService().addFeedback(
            studentId: feedback.studentId,
            feedbackType: feedbackTypeCollection,
            feedbackData: {
              'Final Feedback': finalFeedbackText,
              'Training Course': selectedTraining,
            },
          );
          // Clear text controllers after submission
          taskTitleController.clear();
          taskDescriptionController.clear();
          taskFeedbackController.clear();
        }

        // Feedback added successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback Added Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // You may navigate back or show a confirmation message
      } catch (error) {
        // Handle error
        print("Error adding feedback: $error");
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

      print('Feedback updated successfully');
    } catch (error) {
      print("Error updating feedback: $error");
      throw error; // Rethrow the error for error handling in UI
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
        return '';
      }
    } catch (error) {
      print("Error fetching task ID: $error");
      return '';
    }
  }

  void updateSelectedFeedbackType(String? newValue) {
    selectedFeedbackType = newValue;
    feedbackText = newValue == "Task Feedback" ? "Task Feedback" : "Final Feedback";
    // Reset selected training when changing feedback type
    selectedTraining = null;
    notifyListeners(); // Notify listeners to update the UI
  }
}
