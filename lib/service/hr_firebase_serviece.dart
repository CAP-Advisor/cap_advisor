import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/HR_model.dart';
import '../model/student_model.dart';
import '../model/supervisor_model.dart';

class HRFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;

  Future<List<SupervisorModel>> fetchSupervisors(String hrDocumentId) async {
    var hrDoc = await _firestore.collection('HR').doc(hrDocumentId).get();
    if (hrDoc.exists) {
      var hrId = hrDoc.id;

      var snapshot = await _firestore
          .collection('Supervisor')
          .where('hrId', isEqualTo: hrId)
          .get();
      return snapshot.docs
          .map((doc) => SupervisorModel.fromFirestore(doc))
          .toList();
    }
    return [];
  }

  Future<HR> getHRDataByEmail() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      throw Exception("Email is not available.");
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('HR')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("No HR data available for the email $email.");
      } else {
        DocumentSnapshot doc = snapshot.docs.first;
        return HR.fromFirestore(doc);
      }
    } catch (e) {
      throw Exception("Failed to fetch data: ${e.toString()}");
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

  Future<bool> updateHRProfileImage() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference hrRef = _firestore.collection('HR').doc(userId);

      DocumentSnapshot hrSnapshot = await hrRef.get();

      if (hrSnapshot.exists) {
        await hrRef.update({'photoUrl': imageUrl});
        print("Profile photo updated successfully.");
        return true;
      } else {
        await hrRef.set({
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

  Future<bool> updateHRCoverPhoto() async {
    try {
      String? imageUrl = await uploadImage();
      if (imageUrl == null) {
        print("Image upload failed or was cancelled.");
        return false;
      }

      String userId = _auth.currentUser!.uid;
      DocumentReference hrRef = _firestore.collection('HR').doc(userId);

      DocumentSnapshot hrSnapshot = await hrRef.get();

      if (hrSnapshot.exists) {
        await hrRef.update({'coverPhotoUrl': imageUrl});
        print("Cover photo updated successfully.");
        return true;
      } else {
        print("HR document does not exist.");
        return false;
      }
    } catch (e) {
      print("Error updating cover photo: $e");
      return false;
    }
  }

  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('Job Position').doc(jobId).delete();
  }

  Future<void> deleteTraining(String trainingId) async {
    await _firestore.collection('Training Position').doc(trainingId).delete();
  }

  Future<void> assignStudentToSupervisor(
      String studentId, SupervisorModel supervisor) async {
    final supervisorRef =
        _firestore.collection('Supervisor').doc(supervisor.uid);

    try {
      await supervisorRef.update({
        'studentList': FieldValue.arrayUnion([studentId])
      });
    } catch (e) {
      print("Failed to assign student to supervisor: $e");
      throw e;
    }
  }

  Future<List<Student>> fetchApplicants(
      String positionId, String positionType) async {
    var positionSnapshot =
        await _firestore.collection(positionType).doc(positionId).get();

    List<Student> applicants = [];
    if (positionSnapshot.exists) {
      var studentIds = List<String>.from(
          positionSnapshot.get('studentApplicantsList') ?? []);

      if (studentIds.isNotEmpty) {
        var studentSnapshot = await _firestore
            .collection('Student')
            .where(FieldPath.documentId, whereIn: studentIds)
            .get();
        applicants = studentSnapshot.docs
            .map((doc) => Student.fromFirestore(doc))
            .toList();
      }
    }
    return applicants;
  }
}
