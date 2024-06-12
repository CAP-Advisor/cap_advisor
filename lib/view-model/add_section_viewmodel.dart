import 'package:flutter/material.dart';
import '../service/student_firebase_service.dart';
import '../view/student_view.dart';
import '../exceptions/custom_exception.dart';

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
    try {
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
        throw CustomException('Please fill in at least one field.');
      }

      if (hasCompany) {
        bool success =
            await _firebaseService.addCompany(companyController.text);
        if (!success) {
          throw CustomException("Failed to add company.");
        }
      }

      if (hasTraining) {
        bool success =
            await _firebaseService.addTraining(trainingController.text);
        if (!success) {
          throw CustomException("Failed to add training.");
        }
      }

      if (hasMajor) {
        bool success = await _firebaseService.addMajor(majorController.text);
        if (!success) {
          throw CustomException("Failed to add major.");
        }
      }

      if (hasAddress) {
        bool success = await _firebaseService.addSkill(addressController.text);
        if (!success) {
          throw CustomException("Failed to add address.");
        }
      }

      if (hasSkills) {
        bool success = await _firebaseService.addSkill(skillsController.text);
        if (!success) {
          throw CustomException("Failed to add skill.");
        }
      }

      if (hasExperience) {
        bool success =
            await _firebaseService.addExperience(experienceController.text);
        if (!success) {
          throw CustomException("Failed to add experience.");
        }
      }

      if (hasSummary) {
        bool success =
            await _firebaseService.addSummary(summaryController.text);
        if (!success) {
          throw CustomException("Failed to add summary.");
        }
      }

      if (hasGithub) {
        bool success = await _firebaseService.addGithub(githubController.text);
        if (!success) {
          throw CustomException("Failed to add GitHub.");
        }
      }

      if (hasGpa) {
        try {
          double gpaValue = double.parse(gpaController.text);
          bool success = await _firebaseService.addGpa(gpaValue);
          if (!success) {
            throw CustomException("Failed to add GPA.");
          }
        } catch (e) {
          throw CustomException("Invalid GPA value.");
        }
      }

      notifyListeners();
      showFeedback(context, "Added successfully");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StudentView(
            uid: '',
          ),
        ),
      );
    } catch (e) {
      if (e is CustomException) {
        showFeedback(context, e.message);
      } else {
        showFeedback(context, 'An unexpected error occurred.');
      }
    }
  }

  void showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }
}
