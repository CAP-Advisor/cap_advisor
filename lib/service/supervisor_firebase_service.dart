import 'dart:io';
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
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSupervisorData(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Supervisor')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isEmpty) {
        print('No supervisor found for email: $email');
        return null;
      } else {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('Fetched supervisor data for email $email: $data');
        if (data['name'] != null && data['email'] != null) {
          return data;
        } else {
          print('Data is missing critical fields for email: $email');
          return null;
        }
      }
    } catch (e) {
      print('Error getting supervisor data for email $email: $e');
      return null;
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
        print("No supervisor found with email $email to update");
        return false;
      }
    } catch (e) {
      print("Error updating supervisor name by email: $e");
      return false;
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

  Future<List<Student>> fetchStudentsId(String supervisorId) async {
    try {
      DocumentSnapshot supervisorSnapshot =
          await _firestore.collection('Supervisor').doc(supervisorId).get();
      if (!supervisorSnapshot.exists) {
        print('Supervisor not found');
        return [];
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
      print('Error fetching students: $e');
      return [];
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
      print("Error updating profile image: $e");
      return false;
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
      print("Error updating cover photo: $e");
      return false;
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
      print("Error adding feedback: $error");
      throw error;
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
      print("Error adding Task: $error");
      throw error;
    }
  }
}
