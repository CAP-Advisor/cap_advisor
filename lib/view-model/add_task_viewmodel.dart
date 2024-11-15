import 'package:cap_advisor/resources/colors.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../exceptions/custom_exception.dart';
import '../model/add_task_model.dart';
import 'package:http/http.dart' as http;
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
    String? supervisorEmail = FirebaseAuth.instance.currentUser?.email;
    if (supervisorEmail == null) {
      throw CustomException('Supervisor email is null');
    }

    try {
      Map<String, dynamic>? supervisorData =
          await SupervisorFirebaseService().getSupervisorData(supervisorEmail);
      if (supervisorData != null) {
        supervisorName = supervisorData['name'];
        print('Supervisor Name: $supervisorName');
      } else {
        throw CustomException('Supervisor data not found');
      }
    } catch (error) {
      print('Error fetching supervisor name: $error');
      throw CustomException('Error fetching supervisor name: $error');
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
      final url = Uri.parse(
          'https://pacific-chamber-78827-0f1d28754b89.herokuapp.com/send-notification');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': studentId,
          'title': 'supervisor added task',
          'message': 'the supervisor added tasks',
        }),
      );
      if (response.statusCode != 200) {
        throw CustomException('Failed to send notification');
      }
      taskTitleController.clear();
      taskDescriptionController.clear();
      selectedDeadline = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task added successfully'),
          backgroundColor: successColor,
        ),
      );
      notifyListeners();
    } catch (error) {
      String errorMessage = error is CustomException
          ? error.message
          : 'Error adding task: $error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: errorColor,
        ),
      );
      print(errorMessage);
    }
  }

  void dispose() {
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }
}
