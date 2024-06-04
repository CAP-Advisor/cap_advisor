import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/instructor_model.dart';
import '../model/student_model.dart';

class InstructorFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;

  Future<Instructor?> getInstructorDataByEmail(String email) async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      throw Exception("Email is not available.");
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Instructor')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("No instructor data available for the email $email.");
      } else {
        DocumentSnapshot doc = snapshot.docs.first;
        return Instructor.fromFirestore(doc);
      }
    } catch (e) {
      throw Exception("Failed to fetch data: ${e.toString()}");
    }
  }

  Future<List<Student>> fetchStudentsForInstructor(
      String instructorEmail) async {
    try {
      QuerySnapshot instructorQuery = await _firestore
          .collection('Instructor')
          .where('email', isEqualTo: instructorEmail)
          .limit(1)
          .get();

      if (instructorQuery.docs.isEmpty) {
        print('Instructor not found');
        return [];
      }

      DocumentSnapshot instructorSnapshot = instructorQuery.docs.first;
      List<dynamic> studentRefs = instructorSnapshot['studentList'] ?? [];
      List<Student> students = [];
      for (String studentId in studentRefs) {
        DocumentSnapshot studentSnapshot =
            await _firestore.collection('Student').doc(studentId).get();
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

  Future<String?> uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      String filePath =
          'supervisors/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}.png';
      try {
        TaskSnapshot task = await _storage.ref(filePath).putFile(file);
        String imageUrl = await task.ref.getDownloadURL();
        return imageUrl;
      } catch (e) {
        print('Failed to upload image: $e');
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> updateInstructorProfileImage() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference instructorRef =
          _firestore.collection('Instructor').doc(userId);

      DocumentSnapshot instructorSnapshot = await instructorRef.get();

      if (instructorSnapshot.exists) {
        await instructorRef.update({'photoUrl': imageUrl});
        print("Profile photo updated successfully.");
        return true;
      } else {
        await instructorRef.set({
          'photoUrl': imageUrl,
        }, SetOptions(merge: true));
        print("Profile photo set successfully in new document.");
        return true;
      }
    } catch (e) {
      print("Error updating profile image: $e");
      return false;
    }
  }

  Future<bool> updateInstructorCoverPhoto() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference instructorRef =
          _firestore.collection('Instructor').doc(userId);

      DocumentSnapshot instructorSnapshot = await instructorRef.get();

      if (instructorSnapshot.exists) {
        await instructorRef.update({'coverPhotoUrl': imageUrl});
        print("Cover photo updated successfully.");
        return true;
      } else {
        print("Student document does not exist.");
        return false;
      }
    } catch (e) {
      print("Error updating cover photo: $e");
      return false;
    }
  }
}
