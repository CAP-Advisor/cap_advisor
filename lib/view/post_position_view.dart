import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:cap_advisor/widgets/custom_dropdown_button.dart';
import 'package:cap_advisor/widgets/custom_text_field.dart';
import 'package:cap_advisor/widgets/custom_appbar.dart';
import 'package:cap_advisor/widgets/custom_submit_button.dart';
import 'package:cap_advisor/view-model/post_position_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

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
  String hrId='';

  // Method to get the HR ID
  Future<String?> getHrId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid; // Assuming the HR ID is the user's UID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "CAP Advisor",
        onBack: () {
          Navigator.pop(context);
        },
        onNotificationPressed: () {
          // Handle notification button press
        },
        onMenuPressed: () {
          // Handle menu button press
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "POST POSITION",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9A9A9A),
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomDropdownButton(
              items: const ["Job Position", "Training Position"],
              value: viewModel.positionType,
              hintText: "Position Type",
              onChanged: (value) {
                viewModel.setPositionType(value!);
                setState(() {}); // Update state to show error message
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
            MultiSelectDropDown(
              showClearIcon: true,
              hint: "Select Required Skills",
              onOptionSelected: (options) {
                setState(() {
                  selectedSkills =
                      options.map((e) => e.value).cast<String>().toList();
                });
              },
              options: const <ValueItem>[
                ValueItem(label: 'C++', value: 'c++'),
                ValueItem(label: 'Java', value: 'java'),
                ValueItem(label: 'Java Script', value: 'java_script'),
                ValueItem(label: 'CSS', value: 'css'),
                ValueItem(label: 'HTML', value: 'html'),
                ValueItem(label: 'C#', value: 'c#'),
                ValueItem(label: 'Python', value: 'python'),
                ValueItem(label: 'Scala', value: 'scala'),
                ValueItem(label: 'Nodejs', value: 'nodejs'),
                ValueItem(label: 'Ruby', value: 'ruby'),

                // Add more skills as needed
              ],
              selectionType: SelectionType.multi,
              chipConfig: const ChipConfig(
                wrapType: WrapType.wrap,
                radius: 5,
                backgroundColor: Color(0XFF164863),
              ),
              dropdownHeight: 300,
              optionTextStyle: const TextStyle(
                fontSize: 16,
                fontFamily: "Roboto",
              ),
              selectedOptionIcon: const Icon(
                Icons.check_circle,
                color: Color(0XFF164863),
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
                    _isLoading = true; // Show loading indicator
                  });
                  try {
                    String? hrId = await getHrId(); // Get HR ID
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
                      _isLoading = false; // Hide loading indicator
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
