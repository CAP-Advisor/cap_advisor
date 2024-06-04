import 'package:flutter/material.dart';
import 'package:cap_advisor/widgets/custom_dropdown_button.dart';
import 'package:cap_advisor/widgets/custom_text_field.dart';
import 'package:cap_advisor/widgets/custom_appbar.dart';
import 'package:cap_advisor/widgets/custom_submit_button.dart';
import 'package:cap_advisor/view-model/post_position_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HR_view.dart';

class PostPositionView extends StatefulWidget {
  PostPositionView({
    Key? key,
  }) : super(key: key);

  @override
  _PostPositionViewState createState() => _PostPositionViewState();
}

class _PostPositionViewState extends State<PostPositionView> {
  TextEditingController positionTitleController = TextEditingController();
  TextEditingController positionDescriptionController = TextEditingController();
  List<String>? selectedSkills = [];
  PostPositionViewModel viewModel = PostPositionViewModel();
  bool _isLoading = false;
  String hrId = '';
  final List<String> skills = [
    'C++',
    'Java',
    'Java Script',
    'CSS',
    'HTML',
    'C#',
    'Python',
    'Scala',
    'Nodejs',
    'Ruby',
    'dart',
    'django',
  ];

  Future<String?> getHrId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelectedSkills = List.from(selectedSkills!);
        return AlertDialog(
          title: const Text('Select Required Skills'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: skills.map((skill) {
                    return CheckboxListTile(
                      title: Text(skill, style: TextStyle(color: Colors.black)),
                      value: tempSelectedSkills.contains(skill),
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            tempSelectedSkills.add(skill);
                          });
                        } else {
                          setState(() {
                            tempSelectedSkills.remove(skill);
                          });
                        }
                      },
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedSkills = List.from(tempSelectedSkills);
                });
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.black)),
            ),
          ],
          backgroundColor: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Post Position",
        onBack: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HRView(uid: 'uid'),
            ),
          );
        },
        onNotificationPressed: () {
          // Handle notification button press
        },
        onMenuPressed: () {
          Navigator.of(context).pushNamed('/menu');
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            CustomDropdownButton(
              items: const ["Job Position", "Training Position"],
              value: viewModel.positionType,
              hintText: "Position Type",
              onChanged: (value) {
                viewModel.setPositionType(value!);
                setState(() {});
              },
              errorMessage: 'Required',
              isValid: viewModel.isValidPositionType(),
            ),
            SizedBox(height: 35),
            CustomTextField(
              hintText: 'Position Title',
              controller: positionTitleController,
              onChanged: (value) {},
              errorMessage: 'Enter a Position Title',
              isValid: viewModel.isValidTitle(),
            ),
            SizedBox(height: 35),
            GestureDetector(
              onTap: _showMultiSelectDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F8F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedSkills!.isEmpty
                          ? 'Select Required Skills'
                          : selectedSkills!.join(', '),
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 35),
            CustomTextField(
              hintText: 'Position Description',
              controller: positionDescriptionController,
              onChanged: (value) {},
              errorMessage: 'Enter a brief description',
              isValid: viewModel.isValidDescription(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          String? hrId = await getHrId();
                          if (hrId != null) {
                            await viewModel.savePosition(
                                positionTitleController.text,
                                positionDescriptionController.text,
                                selectedSkills,
                                hrId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Position saved successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HRView(uid: hrId),
                              ),
                            );
                          } else {
                            throw Exception('HR ID not found');
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to save position: ${error.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      text: 'Submit',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
