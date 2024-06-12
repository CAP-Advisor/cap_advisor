import 'package:cap_advisor/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/display_feedback_model.dart';
import '../view-model/display_feedback_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_submit_button.dart';
import '../widgets/custom_text_field.dart';

class DisplayFeedbackView extends StatelessWidget {
  final FeedbackModel feedback;

  DisplayFeedbackView({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DisplayFeedbackViewModel(feedback),
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Feedback",
          onBack: () {
            Navigator.pop(context);
          },
          onMenuPressed: () {
            Navigator.of(context).pushNamed('/menu');
          },
        ),
        body: Consumer<DisplayFeedbackViewModel>(
          builder: (context, viewModel, _) {
            return DisplayFeedbackForm(viewModel: viewModel);
          },
        ),
      ),
    );
  }
}

class DisplayFeedbackForm extends StatefulWidget {
  final DisplayFeedbackViewModel viewModel;

  const DisplayFeedbackForm({required this.viewModel});

  @override
  _DisplayFeedbackFormState createState() => _DisplayFeedbackFormState();
}

class _DisplayFeedbackFormState extends State<DisplayFeedbackForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.viewModel.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 19),
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 30),
              _buildDropDown(context),
              SizedBox(height: 30),
              if (widget.viewModel.selectedFeedbackType != null) ...[
                if (widget.viewModel.selectedFeedbackType ==
                    "Task Feedback") ...[
                  CustomTextField(
                    controller: widget.viewModel.nameController,
                    hintText: "Student Name",
                    readOnly: true,
                    onChanged: (String) {},
                    isValid: widget.viewModel.nameController.text.isNotEmpty,
                    errorMessage: 'Please enter the student name',
                  ),
                  SizedBox(height: 20),
                  _buildTaskTitleDropdown(context),
                ] else if (widget.viewModel.selectedFeedbackType ==
                    "Final Feedback") ...[
                  CustomTextField(
                    controller: widget.viewModel.nameController,
                    hintText: "Student Name",
                    readOnly: true,
                    onChanged: (value) {
                      // Handle onChanged event
                    },
                    isValid: widget.viewModel.nameController.text.isNotEmpty,
                    errorMessage: 'Please enter the student name',
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: widget.viewModel.finalFeedbackController,
                    hintText: "Final Feedback",
                    maxLines: null,
                    isValid: widget.viewModel.nameController.text.isNotEmpty,
                    errorMessage: 'Please enter the final feedback',
                    onChanged: (String) {},
                  ),
                  SizedBox(height: 30),
                ],
                CustomButton(
                  onPressed: () {
                    widget.viewModel.submitFeedback(context);
                  },
                  text: "Submit",
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropDown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.viewModel.selectedFeedbackType,
          onChanged: (String? newValue) {
            setState(() {
              widget.viewModel.updateSelectedFeedbackType(newValue);
            });
          },
          decoration: InputDecoration(
            hintText: 'Feedback Type',
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            fillColor: backgroundBoxColor,
            filled: true,
            hintStyle: TextStyle(
              color: hintTextColor,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          items: widget.viewModel.dropdownItemList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        if (widget.viewModel.selectedFeedbackType == "Final Feedback") ...[
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: widget.viewModel.selectedTraining,
            decoration: InputDecoration(
              hintText: 'Select Training',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              fillColor: backgroundBoxColor,
              filled: true,
              hintStyle: TextStyle(
                color: hintTextColor,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            items:
                ["Training 1", "Training 2", "Training 3"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                widget.viewModel.selectedTraining = newValue;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTaskTitleDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.viewModel.selectedTaskTitle,
          decoration: InputDecoration(
            hintText: 'Select Task Title',
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            fillColor: backgroundBoxColor,
            filled: true,
            hintStyle: TextStyle(
              color: hintTextColor,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          items: widget.viewModel.taskTitles.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) async {
            setState(() {
              widget.viewModel.selectedTaskTitle = newValue;
              widget.viewModel.taskDescriptionController.text =
                  widget.viewModel.titleDescriptionMap[newValue] ?? '';
            });

            if (newValue != null) {
              String taskId = await widget.viewModel.getTaskId(newValue);
              print('Selected Task ID: $taskId');
            }
          },
        ),
        SizedBox(height: 40),
        if (widget.viewModel.selectedTaskTitle != null) ...[
          CustomTextField(
            controller: widget.viewModel.taskDescriptionController,
            hintText: "Task Description",
            readOnly: true,
            onChanged: (String) {},
            errorMessage: 'Please fill the task description',
            isValid: widget.viewModel.nameController.text.isNotEmpty,
          ),
          SizedBox(height: 20),
          CustomTextField(
            controller: widget.viewModel.taskFeedbackController,
            hintText: "Task Feedback",
            maxLines: null,
            onChanged: (String) {},
            errorMessage: 'Please fill the task feedback',
            isValid: widget.viewModel.nameController.text.isNotEmpty,
          ),
          SizedBox(height: 20),
        ],
      ],
    );
  }
}
