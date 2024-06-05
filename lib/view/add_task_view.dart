import 'package:cap_advisor/widgets/custom_deadline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      child:Consumer<AddTaskViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'ADD TASK',
              onBack: () {
                Navigator.of(context).pop();
              },
              onFeedback: (){
                Navigator.of(context).pushNamed('/assign-feedback');
              },
              onNotificationPressed: () {},
              onMenuPressed: () {
                Navigator.of(context).pushNamed('/menu');
              },
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  SizedBox(height: 40),
                  CustomTextField(
                    hintText: "Task Title",
                    controller: model.taskTitleController,
                    onChanged: (value) {},
                    errorMessage: "Please enter a valid title",
                    isValid: !model.showTitleError,
                    showError: model.showTitleError,
                  ),
                  SizedBox(height: 40),
                  CustomTextField(
                    hintText: "Task Description",
                    controller: model.taskDescriptionController,
                    maxLines: null,
                    onChanged: (value) {},
                    errorMessage: "Please enter a valid description",
                    isValid: !model.showDescriptionError,
                    showError: model.showDescriptionError,
                  ),
                  SizedBox(height: 40),
                  CustomDeadline(
                    model: model,
                    showError: model.showDeadlineError,
                  ),
                  SizedBox(height: 50),
                  CustomButton(
                    onPressed: () => model.addTask(context,studentId),
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
