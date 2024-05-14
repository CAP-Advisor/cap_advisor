import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/student_model.dart';
import '../model/supervisor_model.dart';
import '../service/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class SupervisorViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _imageService = FirebaseService();
  final FirebaseService _firestoreService = FirebaseService();

  TextEditingController searchController = TextEditingController();
  List<Student> students = [];
  List<Student> filteredStudents = [];
  SupervisorModel? currentSupervisor;
  String? get supervisorName => currentSupervisor?.name;
  String? get supervisorEmail => currentSupervisor?.email;
  String? get supervisorPhotoUrl => currentSupervisor?.photoUrl;

  SupervisorViewModel();

  Future<bool> updateSupervisorName(String newName) async {
    if (currentSupervisor?.email == null) {
      print("No email available for the current supervisor.");
      return false;
    }
    await _firebaseService.updateSupervisorName(
        currentSupervisor!.email!, newName);
    currentSupervisor?.name = newName;
    return true;
  }

  Future<bool> setCurrentSupervisor() async {
    try {
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        print("No user is currently logged in.");
        return false;
      }

      // Adjusting the query to match based on the 'email' field
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

      print(
          "Supervisor set: ${currentSupervisor?.name}, ${currentSupervisor?.email}, ${currentSupervisor?.photoUrl}, ${currentSupervisor?.coverPhotoUrl}");
      return true;
    } catch (e) {
      print("Error setting current supervisor: $e");
      return false;
    }
  }

  Future<bool> updateProfileImage() async {
    try {
      String? imageUrl = await _imageService.uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference supervisorRef =
          FirebaseFirestore.instance.collection('Supervisor').doc(userId);

      DocumentSnapshot supervisorSnapshot = await supervisorRef.get();

      if (supervisorSnapshot.exists) {
        await supervisorRef.update({'photoUrl': imageUrl});
        print("Profile photo updated successfully.");
        return true;
      } else {
        await supervisorRef.set({
          'photoUrl': imageUrl,
        });
        print("Profile photo set successfully in new document.");
        return true;
      }
    } catch (e) {
      print("Error updating profile image: $e");
      return false;
    }
  }

  Future<List<Student>> fetchStudentsForSupervisor() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        print('User not logged in or email is null');
        return [];
      }
      DocumentSnapshot supervisorSnapshot = await _firestore
          .collection('Supervisor')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      if (!supervisorSnapshot.exists) {
        print('Supervisor not found');

        return [];
      }

      List<dynamic> studentRefs = supervisorSnapshot.get('studentList');
      List<Student> students = [];
      for (var ref in studentRefs) {
        DocumentSnapshot studentSnapshot =
            await _firestore.collection('Student').doc(ref.id).get();
        if (studentSnapshot.exists) {
          students.add(Student.fromFirestore(studentSnapshot));
        }
      }
      return students;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<bool> updateCoverPhoto() async {
    try {
      String? imageUrl = await _imageService.uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference supervisorRef =
          FirebaseFirestore.instance.collection('Supervisor').doc(userId);

      DocumentSnapshot supervisorSnapshot = await supervisorRef.get();
      if (supervisorSnapshot.exists) {
        await supervisorRef.update({'coverPhotoUrl': imageUrl});
        print("Cover photo updated successfully.");
        return true;
      } else {
        print("Supervisor document does not exist.");
        return false;
      }
    } catch (e) {
      print("Error updating cover photo: $e");
      return false;
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
    notifyListeners(); // Ensures UI updates with the new filtered list
  }

  List<Student> filterStudentsList(List<Student> students, String query) {
    if (query.isEmpty) {
      return students;
    }
    return students
        .where((student) =>
            student.name.toLowerCase().contains(query.toLowerCase()) ||
            student.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  notifyListeners();

  // Future<List<Student>> fetchStudents() async {
  //   return _firestoreService.fetchStudents("FWxIs1fcI3TnYGjmRQfsbgSuxbn1");
  // }
}
