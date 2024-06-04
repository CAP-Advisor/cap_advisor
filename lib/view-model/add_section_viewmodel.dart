import 'package:flutter/material.dart';
import '../service/student_firebase_service.dart';
import '../view/student_view.dart';

class SectionViewModel extends ChangeNotifier {
  final StudentFirebaseService _firebaseService;
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController gpaController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController trainingController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  String summaryError = '';
  String majorError = '';
  String githubError = '';
  String gpaError = '';
  String skillsError = '';
  String experienceError = '';
  String addressError = '';
  String companyError = '';
  String trainingError = '';

  bool isSummaryValid = true;
  bool isMajorValid = true;
  bool isGithubValid = true;
  bool isGpaValid = true;
  bool isSkillValid = true;
  bool isExperienceValid = true;
  bool isAddressValid = true;
  bool isCompanyValid = true;
  bool isTrainingValid = true;

  SectionViewModel(this._firebaseService);

  Future<void> addSection(BuildContext context) async {
    summaryError = '';
    majorError = '';
    githubError = '';
    gpaError = '';
    skillsError = '';
    experienceError = '';
    addressError = '';

    isSummaryValid = true;
    isMajorValid = true;
    isGithubValid = true;
    isGpaValid = true;
    isSkillValid = true;
    isExperienceValid = true;
    isAddressValid = true;

    bool hasSummary = summaryController.text.isNotEmpty;
    bool hasMajor = majorController.text.isNotEmpty;
    bool hasGithub = githubController.text.isNotEmpty;
    bool hasGpa = gpaController.text.isNotEmpty;
    bool hasSkills = skillsController.text.isNotEmpty;
    bool hasExperience = experienceController.text.isNotEmpty;
    bool hasAddress = addressController.text.isNotEmpty;
    bool hasCompany = companyController.text.isNotEmpty;
    bool hasTraining = trainingController.text.isNotEmpty;

    if (!hasSummary &&
        !hasMajor &&
        !hasGithub &&
        !hasGpa &&
        !hasSkills &&
        !hasExperience &&
        !hasAddress &&
        !hasTraining &&
        !hasCompany) {
      showFeedback(context, 'Please fill in at least one field.');
      return;
    }

    if (hasCompany) {
      bool success = await _firebaseService.addCompany(companyController.text);
      if (!success) {
        companyError = "Failed to add company.";
        isCompanyValid = false;
        notifyListeners();
        showFeedback(context, companyError);
        return;
      }
    }

    if (hasTraining) {
      bool success =
          await _firebaseService.addTraining(trainingController.text);
      if (!success) {
        trainingError = "Failed to add training.";
        isTrainingValid = false;
        notifyListeners();
        showFeedback(context, trainingError);
        return;
      }
    }

    if (hasMajor) {
      bool success = await _firebaseService.addMajor(majorController.text);
      if (!success) {
        majorError = "Failed to add major.";
        isMajorValid = false;
        notifyListeners();
        showFeedback(context, majorError);
        return;
      }
    }

    if (hasAddress) {
      bool success = await _firebaseService.addSkill(addressController.text);
      if (!success) {
        addressError = "Failed to add address.";
        isAddressValid = false;
        notifyListeners();
        showFeedback(context, addressError);
        return;
      }
    }

    if (hasSkills) {
      bool success = await _firebaseService.addSkill(skillsController.text);
      if (!success) {
        skillsError = "Failed to add skill.";
        isSkillValid = false;
        notifyListeners();
        showFeedback(context, skillsError);
        return;
      }
    }

    if (hasExperience) {
      bool success =
          await _firebaseService.addExperience(experienceController.text);
      if (!success) {
        experienceError = "Failed to add experience.";
        isExperienceValid = false;
        notifyListeners();
        showFeedback(context, experienceError);
        return;
      }
    }

    if (hasSummary) {
      bool success = await _firebaseService.addSummary(summaryController.text);
      if (!success) {
        summaryError = "Failed to add summary.";
        isSummaryValid = false;
        notifyListeners();
        showFeedback(context, summaryError);
        return;
      }
    }

    if (hasGithub) {
      bool success = await _firebaseService.addGithub(githubController.text);
      if (!success) {
        githubError = "Failed to add GitHub.";
        isGithubValid = false;
        notifyListeners();
        showFeedback(context, githubError);
        return;
      }
    }

    if (hasGpa) {
      try {
        double gpaValue = double.parse(gpaController.text);
        bool success = await _firebaseService.addGpa(gpaValue);
        if (!success) {
          gpaError = "Failed to add GPA.";
          isGpaValid = false;
          notifyListeners();
          showFeedback(context, gpaError);
          return;
        }
      } catch (e) {
        gpaError = "Invalid GPA value.";
        isGpaValid = false;
        notifyListeners();
        showFeedback(context, gpaError);
        return;
      }
    }

    notifyListeners();
    showFeedback(context, "Added successfully");

    // Navigate to StudentView
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => StudentView(
          uid: '',
        ),
      ),
    );
  }

  void showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }
}
