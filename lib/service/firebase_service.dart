import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/student_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();

  Future<String?> generateCustomToken(String uid) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? customToken = await user.getIdToken(true);
        print('Generated Custom Token: $customToken');
        return customToken;
      } else {
        print('User is not signed in.');
        return null;
      }
    } catch (e) {
      print('Error generating custom token: $e');
      return null;
    }
  }

  Future<bool> verifyCustomToken(String customToken) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
      User? user = userCredential.user;
      if (user != null) {
        // Check if user is authenticated
        if (user.emailVerified) {
          print('Custom token verified successfully');
          return true;
        } else {
          print('Error verifying custom token: User not authenticated');
          return false;
        }
      } else {
        print('Error verifying custom token: User not authenticated');
        return false;
      }
    } catch (e) {
      print('Error verifying custom token: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserDataFromToken(String token) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      DocumentSnapshot snapshot =
          await _firestore.collection('Users').doc(user.uid).get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      print('Error getting user data from token: $e');
      return null;
    }
  }

  Future<bool> isUserLoggedIn() async {
    var user = _auth.currentUser;
    return user != null;
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      var user = userCredential.user;

      return user != null;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  Future<void> saveToken(String? token) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', token ?? '');
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  Future<void> storeUserData(String userType, String name, String username,
      String email, String password, String uid) async {
    try {
      String hashedPassword = hashPassword(password);
      await _firestore.collection(userType).doc(uid).set({
        'userType': userType,
        'name': name,
        'username': username,
        'email': email,
        'password': hashedPassword,
      });

      await _firestore.collection('Users').doc(uid).set({
        'Uid': uid,
        'email': email,
        'userType': userType,
      });

      print('User data stored successfully in Firestore');
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
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

  Future<String> getHashedPassword(String email) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) => querySnapshot.docs.first);

      if (snapshot.exists) {
        return snapshot['password'];
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error getting hashed password: $e');
      throw Exception('Failed to retrieve hashed password');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        String? userType = userData['userType'];

        if (userType != null) {
          return {'userData': userData, 'userType': userType};
        } else {
          print('User type is null for user: $email');
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

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

  Future<bool> updateProfileImage() async {
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

  Future<bool> updateCoverPhoto() async {
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
}

Future<bool> verifyIdToken(String idToken) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCustomToken(idToken);
    User? user = userCredential.user;
    if (user != null) {
      // Token is valid
      return true;
    } else {
      // Token is invalid
      return false;
    }
  } catch (e) {
    print('Error verifying ID token: $e');
    return false;
  }
}
