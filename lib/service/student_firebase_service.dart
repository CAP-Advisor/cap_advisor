import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/final_feedback_model.dart';
import '../model/student_model.dart';

class StudentFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> fetchStudentData(String? userId) async {
    if (userId == null) return null;
    try {
      DocumentSnapshot studentDoc =
          await _firestore.collection('Student').doc(userId).get();
      if (studentDoc.exists) {
        return studentDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching student data: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTasksForSpecificStudent(
      String studentId) async {
    try {
      Map<String, dynamic>? studentDoc = await fetchStudentData(studentId);
      if (studentDoc != null) {
        QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
            .collection('Student')
            .doc(studentId)
            .collection('Task')
            .get();
        return taskSnapshot.docs
            .map((taskDoc) => taskDoc.data() as Map<String, dynamic>)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  Future<Student?> getStudentDataByUid(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('Student').doc(uid).get();

      if (!snapshot.exists) {
        return null;
      } else {
        return Student.fromFirestore(snapshot);
      }
    } catch (e) {
      throw Exception("Failed to fetch data: ${e.toString()}");
    }
  }

  Future<Student?> getStudentDataByEmail() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      throw Exception("Email is not available.");
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Student')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("No student data available for the email $email.");
      } else {
        DocumentSnapshot doc = snapshot.docs.first;
        return Student.fromFirestore(doc);
      }
    } catch (e) {
      throw Exception("Failed to fetch data: ${e.toString()}");
    }
  }

  Future<List<Student>> fetchStudents() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Student').get();
      List<Student> students =
          querySnapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      return students;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<bool> updateStudentName(String email, String newName) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('Student')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'name': newName});
        print("Updated student name for email $email to $newName");
        return true;
      } else {
        print("No student found with email $email to update");
        return false;
      }
    } catch (e) {
      print("Error updating student name by email: $e");
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

  Future<bool> updateStudentProfileImage() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference studentRef =
          _firestore.collection('Student').doc(userId);

      DocumentSnapshot studentSnapshot = await studentRef.get();

      if (studentSnapshot.exists) {
        await studentRef.update({'photoUrl': imageUrl});
        print("Profile photo updated successfully.");
        return true;
      } else {
        await studentRef.set({
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

  Future<bool> updateStudentCoverPhoto() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference studentRef =
          _firestore.collection('Student').doc(userId);

      DocumentSnapshot studentSnapshot = await studentRef.get();

      if (studentSnapshot.exists) {
        await studentRef.update({'coverPhotoUrl': imageUrl});
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

  Future<List<FinalTraining>> fetchTrainingDataByEmail(String email) async {
    if (email.isEmpty) return [];

    try {
      print("Fetching training data for email: $email");
      QuerySnapshot trainingSnapshot = await FirebaseFirestore.instance
          .collection('Student')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (trainingSnapshot.docs.isNotEmpty) {
        final studentDoc = trainingSnapshot.docs.first;
        final uid = studentDoc.id;

        QuerySnapshot trainingData = await FirebaseFirestore.instance
            .collection('Student')
            .doc(uid)
            .collection('Training')
            .get();

        return trainingData.docs
            .map((doc) => FinalTraining.fromDocument(doc))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Failed to fetch training data: ${e.toString()}");
      return [];
    }
  }

  Future<bool> addGithub(String github) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await _firestore
          .collection('Student')
          .doc(userId)
          .update({'github': github});
      return true;
    } catch (e) {
      print("Failed to add github link");
      return false;
    }
  }

  Future<bool> addGpa(double gpa) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await _firestore.collection('Student').doc(userId).update({'gpa': gpa});
      return true;
    } catch (e) {
      print("Failed to add GPA: $e");
      return false;
    }
  }

  Future<bool> addAddress(String address) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await _firestore
          .collection('Student')
          .doc(userId)
          .update({'address': address});
      return true;
    } catch (e) {
      print("Failed to add Address");
      return false;
    }
  }

  Future<bool> addExperience(String experience) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await _firestore.collection('Student').doc(userId).update({
        'experience': FieldValue.arrayUnion([experience])
      });
      return true;
    } catch (e) {
      print("Failed to add experience: $e");
      return false;
    }
  }

  Future<bool> addSkill(String skill) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await _firestore.collection('Student').doc(userId).update({
        'skills': FieldValue.arrayUnion([skill])
      });
      return true;
    } catch (e) {
      print("Failed to add skill: $e");
      return false;
    }
  }

  Future<bool> addSummary(String summary) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await FirebaseFirestore.instance
          .collection('Student')
          .doc(userId)
          .update({'summary': summary});
      return true;
    } catch (e) {
      print("Failed to add summary: $e");
      return false;
    }
  }

  Future<bool> addMajor(String major) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await FirebaseFirestore.instance
          .collection('Student')
          .doc(userId)
          .update({'additionalInfo': major});
      return true;
    } catch (e) {
      print("Failed to add major");
      return false;
    }
  }

  Future<bool> addCompany(String company) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await FirebaseFirestore.instance
          .collection('Student')
          .doc(userId)
          .update({'company': company});
      return true;
    } catch (e) {
      print("Failed to add company");
      return false;
    }
  }

  Future<bool> addTraining(String training) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    try {
      await FirebaseFirestore.instance
          .collection('Student')
          .doc(userId)
          .update({'training': training});
      return true;
    } catch (e) {
      print("Failed to add training");
      return false;
    }
  }
}
