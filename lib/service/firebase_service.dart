import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/firebaseuser.dart';
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCustomToken(customToken);
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

      DocumentSnapshot snapshot = await _firestore.collection('Users').doc(
          user.uid).get();

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
      QuerySnapshot querySnapshot = await _firestore.collection('Users').where(
          'email', isEqualTo: email).get();
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

      UserCredential userData = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection(userType).doc(uid).set({
        'userType': userType,
        'name': name,
        'username': username,
        'email': email,
        'password': hashedPassword,
      });

      await _firestore.collection('Users').add({
        'email': email,
        'userType': userType,
        'username':username,
        'name':name,
        'Uid':userData.user?.uid
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
      QuerySnapshot querySnapshot = await _firestore.collection('Users').where(
          'email', isEqualTo: email).get();


      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = querySnapshot.docs.first.data() as Map<
            String,
            dynamic>;
        String? userType = userData['userType'];

        if (userType != null) {
          return {
            'userData': userData,
            'userType': userType
          };
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
}

  Future<bool> verifyIdToken(String idToken) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(idToken);
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