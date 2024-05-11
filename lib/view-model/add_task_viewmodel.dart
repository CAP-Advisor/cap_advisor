import 'package:flutter/material.dart';
import '../model/add_task_model.dart';
import '../service/firebase_service.dart';

class AddTaskViewModel extends ChangeNotifier {
  late TextEditingController taskTitleController;
  late TextEditingController taskDescriptionController;
  DateTime? selectedDeadline;

  AddTaskViewModel() {
    taskTitleController = TextEditingController();
    taskDescriptionController = TextEditingController();
  }

  Future<void> addTask(String studentId) async {
    if (taskTitleController.text.isEmpty ||
        taskDescriptionController.text.isEmpty ||
        selectedDeadline == null) {
      return;
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
