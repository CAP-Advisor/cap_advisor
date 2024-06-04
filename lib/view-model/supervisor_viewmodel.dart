import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        print("No user is currently logged in.");
        return false;
      }
      QuerySnapshot querySnapshot = await _firestore
          .collection('Supervisor')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        print("No supervisor found for email $email");
        return false;
      }
      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      currentSupervisor = SupervisorModel.fromDocSnapshot(docSnapshot);
      notifyListeners();
      return true;
    } catch (e) {
      print("Error setting current supervisor: $e");
      return false;
    }
  }

  Future<void> loadStudentsForSupervisor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      print('User not logged in or email is null');
      return;
    }
    students = await _firebaseService.fetchStudentsForSupervisor(user.email!);
    filteredStudents = List<Student>.from(students);
    notifyListeners();
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
    if (currentSupervisor?.email == null) {
      print("No email available for the current supervisor.");
      return false;
    }
    bool updateResult = await _firebaseService.updateSupervisorName(
        currentSupervisor!.email!, newName);
    if (updateResult) {
      currentSupervisor?.name = newName;
      print("Name updated successfully to $newName.");
      notifyListeners();
      return true;
    } else {
      print("Failed to update name.");
      return false;
    }
  }

  Future<bool> updateSupervisorProfileImage() async {
    bool result = await _firebaseService.updateSupervisorProfileImage();
    if (result) {
      print("Profile image updated successfully.");
    } else {
      print("Failed to update profile image.");
    }
    return result;
  }

  Future<bool> updateSupervisorCoverPhoto() async {
    bool result = await _firebaseService.updateSupervisorCoverPhoto();
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
