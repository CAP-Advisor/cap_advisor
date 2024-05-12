import 'package:flutter/material.dart';
import '../model/add_task_model.dart';
import '../service/firebase_service.dart';

class AddTaskViewModel extends ChangeNotifier {
  late TextEditingController taskTitleController;
  late TextEditingController taskDescriptionController;
  DateTime? selectedDeadline;
  bool showTitleError = false;
  bool showDescriptionError = false;
  bool showDeadlineError = false;

  AddTaskViewModel() {
    taskTitleController = TextEditingController();
    taskDescriptionController = TextEditingController();
  }

  Future<void> addTask(String studentId) async {
    // Reset error flags
    showTitleError = false;
    showDescriptionError = false;
    showDeadlineError = false;

    if (taskTitleController.text.isEmpty) {
      showTitleError = true;
    }
    if (taskDescriptionController.text.isEmpty) {
      showDescriptionError = true;
    }
    if (selectedDeadline == null) {
      showDeadlineError = true;
    }

    // Check if any error flag is set
    if (showTitleError || showDescriptionError || showDeadlineError) {
      notifyListeners();
      return; // Exit early if there are errors
    }

    TaskModel task = TaskModel(
      title: taskTitleController.text,
      description: taskDescriptionController.text,
      deadline: selectedDeadline!,
    );

    try {
      await FirebaseService().addTask(
        studentId: studentId,
        taskData: task.toMap(),
      );
      notifyListeners();
    } catch (error) {
      print("Error adding task: $error");
    }
  }

  void dispose() {
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }
}
