import 'package:cap_advisor/widgets/custom_deadline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view-model/add_task_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_submit_button.dart';
import '../widgets/custom_text_field.dart';

class AddTaskView extends StatelessWidget {
  final String studentId;
  final String studentName;

  AddTaskView({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddTaskViewModel(),
      child: Consumer<AddTaskViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'CAP Advisor',
              onBack: () {
                Navigator.of(context).pop();
              },
              onNotificationPressed: () {},
              onMenuPressed: () {},
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "ADD TASK",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  CustomTextField(
                    hintText: "Task Title",
                    controller: model.taskTitleController,
                    onChanged: (value) {},
                    errorMessage: "Please enter a valid title",
                    isValid: true, // Set to true/false based on validation
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    hintText: "Task Description",
                    controller: model.taskDescriptionController,
                    onChanged: (value) {},
                    errorMessage: "Please enter a valid description",
                    isValid: true, // Set to true/false based on validation
                  ),
                  SizedBox(height: 20),
                  CustomDeadline(model: model),
                  SizedBox(height: 30),
                  CustomButton(
                    // Use the custom button widget
                    onPressed: () => model.addTask(studentId),
                    text: "Submit",
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
