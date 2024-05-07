import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<void> storeUserData(String userType, String name, String username, String email, String password) async {
    try {
      String hashedPassword = hashPassword(password);

      await _firestore.collection(userType).add({
        'userType': userType,
        'name': name,
        'username': username,
        'email': email,
        'password': hashedPassword,
      });

      await _firestore.collection('Users').add({
        'email': email,
        'password': hashedPassword,
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
          return {
            'userData': userData,
            'userType': userType
          };
        } else {
          print('User type is null for user: $email');
          return null;
        }
      } else {
        return null; // User data not found
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }
}
