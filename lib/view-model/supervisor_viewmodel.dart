import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../exceptions/custom_exception.dart';
import '../model/student_model.dart';
import '../model/supervisor_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../service/supervisor_firebase_service.dart';

class SupervisorViewModel extends ChangeNotifier {
  final SupervisorFirebaseService _firebaseService =
      SupervisorFirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();

  List<Student> students = [];
  List<Student> filteredStudents = [];
  SupervisorModel? currentSupervisor;
  String? get supervisorName => currentSupervisor?.name;
  String? get supervisorEmail => currentSupervisor?.email;
  String? get supervisorPhotoUrl => currentSupervisor?.photoUrl;

  SupervisorViewModel() {
    _init();
  }

  void _init() async {
    await setCurrentSupervisor();
    await loadStudentsForSupervisor();
    searchController.addListener(() {
      filterStudents(searchController.text);
    });
  }

  Future<bool> setCurrentSupervisor() async {
    try {
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        throw CustomException("No user is currently logged in.");
      }
      QuerySnapshot querySnapshot = await _firestore
          .collection('Supervisor')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw CustomException("No supervisor found for email $email");
      }
      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      currentSupervisor = SupervisorModel.fromDocSnapshot(docSnapshot);
      notifyListeners();
      return true;
    } catch (e) {
      print("Error setting current supervisor: $e");
      throw CustomException("Error setting current supervisor: $e");
    }
  }

  Future<void> loadStudentsForSupervisor() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw CustomException('User not logged in or email is null');
      }
      students = await _firebaseService.fetchStudentsForSupervisor(user.email!);
      filteredStudents = List<Student>.from(students);
      notifyListeners();
    } catch (e) {
      print("Error loading students: $e");
      throw CustomException("Error loading students: $e");
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

  Future<bool> updateSupervisorName(String newName) async {
    try {
      if (currentSupervisor?.email == null) {
        throw CustomException("No email available for the current supervisor.");
      }
      bool updateResult = await _firebaseService.updateSupervisorName(
          currentSupervisor!.email!, newName);
      if (updateResult) {
        currentSupervisor?.name = newName;
        notifyListeners();
        return true;
      } else {
        throw CustomException("Failed to update name.");
      }
    } catch (e) {
      print("Error updating supervisor name: $e");
      throw CustomException("Error updating supervisor name: $e");
    }
  }

  Future<bool> updateSupervisorProfileImage() async {
    try {
      bool result = await _firebaseService.updateSupervisorProfileImage();
      if (!result) {
        throw CustomException("Failed to update profile image.");
      }
      notifyListeners();
      return result;
    } catch (e) {
      print("Error updating profile image: $e");
      throw CustomException("Error updating profile image: $e");
    }
  }

  Future<bool> updateSupervisorCoverPhoto() async {
    try {
      bool result = await _firebaseService.updateSupervisorCoverPhoto();
      if (!result) {
        throw CustomException("Failed to update cover photo.");
      }
      notifyListeners();
      return result;
    } catch (e) {
      print("Error updating cover photo: $e");
      throw CustomException("Error updating cover photo: $e");
    }
  }

  Future<void> handleProfileAction(BuildContext context, String value) async {
    try {
      switch (value) {
        case 'view_profile_photo':
          if (currentSupervisor?.photoUrl != null) {
            _showImageDialog(
                context, currentSupervisor!.photoUrl!, 'Profile Photo');
          }
          break;
        case 'view_cover_photo':
          if (currentSupervisor?.coverPhotoUrl != null) {
            _showImageDialog(
                context, currentSupervisor!.coverPhotoUrl!, 'Cover Photo');
          }
          break;
        case 'choose_profile_photo':
          var result = await updateSupervisorProfileImage();
          _showSnackBar(context, result, 'Profile photo updated successfully!',
              'Failed to update profile photo.');
          break;
        case 'choose_cover_photo':
          var result = await updateSupervisorCoverPhoto();
          _showSnackBar(context, result, 'Cover photo updated successfully!',
              'Failed to update cover photo.');
          break;
      }
    } catch (e) {
      if (e is CustomException) {
        _showSnackBar(context, false, '', e.toString());
      } else {
        _showSnackBar(context, false, '', 'An unexpected error occurred.');
      }
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
