import 'package:cap_advisor/model/student_model.dart';
import 'package:flutter/material.dart';
import '../exceptions/custom_exception.dart';
import '../model/final_feedback_model.dart';
import '../service/student_firebase_service.dart';

class StudentViewModel with ChangeNotifier {
  final StudentFirebaseService _firebaseService = StudentFirebaseService();
  bool isLoading = false;
  String? error;
  final String uid;
  Student? currentStudent;
  List<FinalTraining> trainings = [];
  String? get studentName => currentStudent?.name;
  String? get studentEmail => currentStudent?.email;
  String? get studentPhotoUrl => currentStudent?.photoUrl;

  StudentViewModel(this.uid) {
    print("StudentViewModel initialized with uid: $uid");
    if (uid.isNotEmpty) {
      getStudentDataByUid().then((_) {
        if (currentStudent?.email != null) {
          fetchTrainingDataByEmail(currentStudent!.email);
        }
      });
    } else {
      getStudentDataByEmail().then((_) {
        if (currentStudent?.email != null) {
          fetchTrainingDataByEmail(currentStudent!.email);
        }
      });
    }
  }

  Future<void> getStudentDataByEmail() async {
    isLoading = true;
    notifyListeners();

    try {
      currentStudent = await _firebaseService.getStudentDataByEmail();
      if (currentStudent == null) {
        throw CustomException("No student data available.");
      } else {
        fetchTrainingDataByEmail(currentStudent!.email);
      }
    } catch (e) {
      error = e is CustomException ? e.message : e.toString();
      throw CustomException("Failed to fetch student data by email: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getStudentDataByUid() async {
    isLoading = true;
    notifyListeners();

    try {
      currentStudent = await _firebaseService.getStudentDataByUid(uid);
      if (currentStudent == null) {
        throw CustomException("No student data available for the uid $uid.");
        ;
      } else {
        fetchTrainingDataByEmail(currentStudent!.email);
      }
    } catch (e) {
      error = e is CustomException ? e.message : e.toString();
      throw CustomException("Failed to fetch student data by UID: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStudentName(String newName) async {
    if (currentStudent?.email == null) {
      throw CustomException("No email available for the current student.");
    }
    bool updateResult = await _firebaseService.updateStudentName(
        currentStudent!.email, newName);
    if (updateResult) {
      currentStudent?.name = newName;
      print("Name updated successfully to $newName.");
      notifyListeners();
      return true;
    } else {
      throw CustomException("Failed to update name.");
    }
  }

  Future<bool> updateStudentProfileImage() async {
    try {
      bool result = await _firebaseService.updateStudentProfileImage();
      if (!result) {
        throw CustomException("Failed to update profile image.");
      }
      print("Profile image updated successfully.");
      return result;
    } catch (e) {
      error = e is CustomException ? e.message : e.toString();
      throw CustomException("Failed to update profile image: $error");
    }
  }

  Future<bool> updateStudentCoverPhoto() async {
    try {
      bool result = await _firebaseService.updateStudentCoverPhoto();
      if (!result) {
        throw CustomException("Failed to update cover photo.");
      }
      print("Cover photo updated successfully.");
      return result;
    } catch (e) {
      error = e is CustomException ? e.message : e.toString();
      throw CustomException("Failed to update cover photo: $error");
    }
  }

  Future<void> handleProfileAction(BuildContext context, String value) async {
    switch (value) {
      case 'view_profile_photo':
        if (currentStudent?.photoUrl != null) {
          _showImageDialog(context, currentStudent!.photoUrl!, 'Profile Photo');
        }
        break;
      case 'view_cover_photo':
        if (currentStudent?.coverPhotoUrl != null) {
          _showImageDialog(
              context, currentStudent!.coverPhotoUrl!, 'Cover Photo');
        }
        break;
      case 'choose_profile_photo':
        var result = await updateStudentProfileImage();
        _showSnackBar(context, result, 'Profile photo updated successfully!',
            'Failed to update profile photo.');
        break;
      case 'choose_cover_photo':
        var result = await updateStudentCoverPhoto();
        _showSnackBar(context, result, 'Cover photo updated successfully!',
            'Failed to update cover photo.');
        break;
    }
  }

  void _showSnackBar(BuildContext context, bool result, String successMessage,
      String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? successMessage : errorMessage),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Image.network(
            imageUrl,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            fit: BoxFit.contain,
            width: double.maxFinite,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchTrainingDataByEmail(String email) async {
    isLoading = true;
    notifyListeners();

    try {
      trainings = await _firebaseService.fetchTrainingDataByEmail(email);
      print('Fetched ${trainings.length} training records.');
    } catch (e) {
      error = "Failed to fetch training data: ${e.toString()}";
      throw CustomException(error!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
