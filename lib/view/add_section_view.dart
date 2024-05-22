import 'package:flutter/material.dart';
import 'package:cap_advisor/service/firebase_service.dart';
import 'package:provider/provider.dart';
import '../view-model/add_section_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_submit_button.dart';
import '../widgets/custom_text_field.dart';

class SectionView extends StatelessWidget {
  final FirebaseService firebaseService;

  SectionView({Key? key, required this.firebaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SectionViewModel>(
      create: (_) => SectionViewModel(firebaseService),
      child: Consumer<SectionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "Add Section",
              onBack: () => Navigator.of(context).pop(),
              onNotificationPressed: () {},
              onJobPressed: () {},
              onMenuPressed: () => Navigator.of(context).pushNamed('/menu'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Text(
                      "Summary",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "Summary",
                      controller: viewModel.summaryController,
                      onChanged: (value) {},
                      errorMessage: viewModel.summaryError,
                      isValid: viewModel.isSummaryValid,
                      showError: !viewModel.isSummaryValid,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Major",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "Major (AI,Software Engineering) (required)",
                      controller: viewModel.majorController,
                      onChanged: (value) {},
                      errorMessage: viewModel.majorError,
                      isValid: viewModel.isMajorValid,
                      showError: !viewModel.isMajorValid,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "GitHub",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "GitHub Link",
                      controller: viewModel.githubController,
                      onChanged: (value) {},
                      errorMessage: viewModel.githubError,
                      isValid: viewModel.isGithubValid,
                      showError: !viewModel.isGithubValid,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "GPA",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "GPA (ex:3.5)",
                      controller: viewModel.gpaController,
                      onChanged: (value) {},
                      errorMessage: viewModel.gpaError,
                      isValid: viewModel.isGpaValid,
                      showError: !viewModel.isGpaValid,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Address",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "Address",
                      controller: viewModel.addressController,
                      onChanged: (value) {},
                      errorMessage: viewModel.addressError,
                      isValid: viewModel.isAddressValid,
                      showError: !viewModel.isAddressValid,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Skills",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "Skills (ex: Project Management)",
                      controller: viewModel.skillsController,
                      onChanged: (value) {},
                      errorMessage: viewModel.skillsError,
                      isValid: viewModel.isSkillValid,
                      showError: !viewModel.isSkillValid,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Experience",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText:
                          "Experience (ex: 5 years of project management)",
                      controller: viewModel.experienceController,
                      onChanged: (value) {},
                      errorMessage: viewModel.experienceError,
                      isValid: viewModel.isExperienceValid,
                      showError: !viewModel.isExperienceValid,
                    ),
                    SizedBox(height: 150),
                    Center(
                      child: CustomButton(
                        onPressed: () => viewModel.addSection(context),
                        text: "Submit",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
