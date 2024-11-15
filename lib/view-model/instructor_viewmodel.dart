import 'package:cap_advisor/model/instructor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../exceptions/custom_exception.dart';
import '../model/student_model.dart';
import '../service/instructor_firebase_service.dart';

class InstructorViewModel with ChangeNotifier {
  final InstructorFirebaseService _firebaseService =
      InstructorFirebaseService();
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  String? error;
  final String uid;
  Instructor? currentInstructor;
  String? get instructorName => currentInstructor?.name;
  String? get instructorEmail => currentInstructor?.email;
  String? get instructorPhotoUrl => currentInstructor?.photoUrl;
  List<Student> students = [];
  List<Student> filteredStudents = [];

  InstructorViewModel(this.uid) {
    print("InstructorViewModel initialized with uid: $uid");
    if (uid.isNotEmpty) {
      getInstructorData().then((_) {
        loadStudentsForInstructorView();
      });
    } else {
      getInstructorDataByUid().then((_) {
        loadStudentsForInstructor();
      });
    }
  }

  Future<void> loadStudentsForInstructorView() async {
    if (currentInstructor == null) {
      error = 'Instructor data is not loaded';
      notifyListeners();
      return;
    }

    try {
      print(
          "Fetching students for instructor email: ${currentInstructor!.email}");
      students = await _firebaseService
          .fetchStudentsForInstructor(currentInstructor!.email);
      print("Number of students fetched: ${students.length}");
      filteredStudents = List<Student>.from(students);
      notifyListeners();
    } catch (e) {
      error = 'Failed to fetch students: $e';
      notifyListeners();
      throw CustomException("Failed to fetch students: $e");
    }
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredStudents = List<Student>.from(students);
    } else {
      query = query.toLowerCase();
      filteredStudents = students.where((student) {
        return student.name.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> getInstructorDataByUid() async {
    isLoading = true;
    notifyListeners();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Fetching instructor data for email: ${user.email}");
        currentInstructor =
            await _firebaseService.getInstructorDataByEmail(user.email!);
      }
      if (currentInstructor == null) {
        error = "No instructor data available.";
        throw CustomException("No instructor data available.");
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
      throw CustomException("Error in getInstructorDataByUid: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getInstructorData() async {
    isLoading = true;
    notifyListeners();

    try {
      currentInstructor = await _firebaseService.getInstructorDataByUid(uid);
      if (currentInstructor == null) {
        error = "No instructor data available for the uid $uid.";
        throw CustomException("No instructor data available for the uid $uid.");
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
      throw CustomException("Error in getInstructorData: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentsForInstructor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      error = 'User not logged in or email is null';
      notifyListeners();
      throw CustomException('User not logged in or email is null');
    }
    try {
      print("Fetching students for instructor email: ${user.email}");
      students = await _firebaseService.fetchStudentsForInstructor(user.email!);
      print("Number of students fetched: ${students.length}");
      filteredStudents = List<Student>.from(students);
      notifyListeners();
    } catch (e) {
      error = 'Failed to fetch students: $e';
      notifyListeners();
      throw CustomException("Error in loadStudentsForInstructor: $e");
    }
  }

  Future<bool> updateInstructorProfileImage() async {
    bool result = await _firebaseService.updateInstructorProfileImage();
    if (result) {
      print("Profile image updated successfully.");
    } else {
      print("Failed to update profile image.");
    }
    return result;
  }

  Future<bool> updateInstructorCoverPhoto() async {
    bool result = await _firebaseService.updateInstructorCoverPhoto();
    if (result) {
      print("Cover photo updated successfully.");
    } else {
      print("Failed to update cover photo.");
    }
    return result;
  }

  Future<void> handleProfileAction(BuildContext context, String value) async {
    switch (value) {
      case 'view_profile_photo':
        if (currentInstructor?.photoUrl != null) {
          _showImageDialog(
              context, currentInstructor!.photoUrl!, 'Profile Photo');
        }
        break;
      case 'view_cover_photo':
        if (currentInstructor?.coverPhotoUrl != null) {
          _showImageDialog(
              context, currentInstructor!.coverPhotoUrl!, 'Cover Photo');
        }
        break;
      case 'choose_profile_photo':
        var result = await updateInstructorProfileImage();
        _showSnackBar(context, result, 'Profile photo updated successfully!',
            'Failed to update profile photo.');
        break;
      case 'choose_cover_photo':
        var result = await updateInstructorCoverPhoto();
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
}
