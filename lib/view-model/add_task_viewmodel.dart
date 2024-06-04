import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/add_task_model.dart';
import '../service/firebase_service.dart';
import '../service/supervisor_firebase_service.dart';

class AddTaskViewModel extends ChangeNotifier {
  late TextEditingController taskTitleController;
  late TextEditingController taskDescriptionController;
  DateTime? selectedDeadline;
  bool showTitleError = false;
  bool showDescriptionError = false;
  bool showDeadlineError = false;
  String? supervisorName;

  AddTaskViewModel() {
    taskTitleController = TextEditingController();
    taskDescriptionController = TextEditingController();
    fetchSupervisorName();
  }
  Future<void> fetchSupervisorName() async {
    try {
      String? supervisorEmail = FirebaseAuth.instance.currentUser?.email;
      if (supervisorEmail != null) {
        Map<String, dynamic>? supervisorData = await SupervisorFirebaseService()
            .getSupervisorData(supervisorEmail);
        if (supervisorData != null) {
          supervisorName = supervisorData['name'];
          print('Supervisor Name: $supervisorName');
        } else {
          print('Supervisor data not found');
        }
      }
    } catch (error) {
      print('Error fetching supervisor name: $error');
    }
  }

  Future<void> addTask(BuildContext context, String studentId) async {
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

    if (showTitleError || showDescriptionError || showDeadlineError) {
      notifyListeners();
      return;
    }
    TaskModel task = TaskModel(
      title: taskTitleController.text,
      description: taskDescriptionController.text,
      deadline: selectedDeadline!,
      supervisorName: supervisorName,
    );

    try {
      await SupervisorFirebaseService().addTask(
        studentId: studentId,
        taskData: task.toMap(),
      );
      taskTitleController.clear();
      taskDescriptionController.clear();
      selectedDeadline = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      notifyListeners();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding task: $error'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error adding task: $error");
    }
  }

  void dispose() {
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }
}
