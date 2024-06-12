import 'dart:io';
import 'package:cap_advisor/exceptions/custom_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/student_model.dart';

class SupervisorFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;

  Future<List<Student>> fetchStudentsForSupervisor(
      String supervisorEmail) async {
    try {
      QuerySnapshot supervisorQuery = await _firestore
          .collection('Supervisor')
          .where('email', isEqualTo: supervisorEmail)
          .limit(1)
          .get();

      if (supervisorQuery.docs.isEmpty) {
        print('Supervisor not found');
        return [];
      }

      DocumentSnapshot supervisorSnapshot = supervisorQuery.docs.first;
      List<dynamic> studentRefs = supervisorSnapshot['studentList'] ?? [];
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
      throw CustomException('Error fetching students: $e');
    }
  }

  Future<Map<String, dynamic>?> getSupervisorData(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Supervisor')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw CustomException('No supervisor found for email: $email');
      } else {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('Fetched supervisor data for email $email: $data');
        if (data['name'] != null && data['email'] != null) {
          return data;
        } else {
          throw CustomException(
              'Data is missing critical fields for email: $email');
        }
      }
    } catch (e) {
      throw CustomException(
          'Error getting supervisor data for email $email: $e');
    }
  }

  Future<bool> updateSupervisorName(String email, String newName) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('Supervisor')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'name': newName});
        print("Updated supervisor name for email $email to $newName");
        return true;
      } else {
        throw CustomException(
            'No supervisor found with email $email to update');
      }
    } catch (e) {
      throw CustomException('Error updating supervisor name by email: $e');
    }
  }

  Future<String?> uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File file = File(image.path);
        String filePath =
            'supervisor/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}.png';
        TaskSnapshot task = await _storage.ref(filePath).putFile(file);
        String imageUrl = await task.ref.getDownloadURL();
        return imageUrl;
      } else {
        throw CustomException("Image upload cancelled.");
      }
    } catch (e) {
      throw CustomException("Failed to upload image: $e");
    }
  }

  Future<List<Student>> fetchStudentsId(String supervisorId) async {
    try {
      DocumentSnapshot supervisorSnapshot =
          await _firestore.collection('Supervisor').doc(supervisorId).get();
      if (!supervisorSnapshot.exists) {
        throw CustomException('Supervisor not found');
      } else {
        print('Fetched supervisor data for email ${supervisorSnapshot.data()}');
      }
      List<dynamic> studentList = supervisorSnapshot.get('studentList');
      QuerySnapshot querySnapshot = await _firestore
          .collection('Student')
          .where(FieldPath.documentId, whereIn: studentList)
          .get();
      List<Student> students =
          querySnapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      return students;
    } catch (e) {
      throw CustomException('Error fetching students: $e');
    }
  }

  Future<bool> updateSupervisorProfileImage() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference supervisorRef =
          _firestore.collection('Supervisor').doc(userId);

      DocumentSnapshot supervisorSnapshot = await supervisorRef.get();

      if (supervisorSnapshot.exists) {
        await supervisorRef.update({'photoUrl': imageUrl});
        print("Profile photo updated successfully.");
        return true;
      } else {
        await supervisorRef.set({
          'photoUrl': imageUrl,
        }, SetOptions(merge: true));
        print("Profile photo set successfully in new document.");
        return true;
      }
    } catch (e) {
      throw CustomException("Error updating profile image: $e");
    }
  }

  Future<bool> updateSupervisorCoverPhoto() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference supervisorRef =
          _firestore.collection('Supervisor').doc(userId);

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
      throw CustomException("Error updating cover photo: $e");
    }
  }

  Future<void> addFeedback({
    required String studentId,
    required String feedbackType,
    required Map<String, dynamic> feedbackData,
  }) async {
    try {
      DocumentReference studentRef =
          FirebaseFirestore.instance.collection('Student').doc(studentId);

      CollectionReference feedbackCollection =
          studentRef.collection(feedbackType);

      await feedbackCollection.add(feedbackData);

      print('Feedback added successfully');
    } catch (error) {
      throw CustomException("Error adding feedback: $error");
    }
  }

  Future<void> addTask({
    required String studentId,
    required Map<String, dynamic> taskData,
  }) async {
    try {
      DocumentReference studentRef =
          FirebaseFirestore.instance.collection('Student').doc(studentId);
      await studentRef.collection('Task').add(taskData);
      print('Task added successfully');
    } catch (error) {
      throw CustomException("Error adding Task: $error");
    }
  }
}
