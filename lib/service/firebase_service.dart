import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      String hashedPassword = _hashPassword(password);

      await _firestore.collection(userType).doc(uid).set({
        'userType': userType,
        'name': name,
        'username': username,
        'email': email,
        'password': hashedPassword,
      });

      await _firestore.collection('Users').doc(uid).set({
        'email': email,
        'password': hashedPassword,
        'userType': userType,
      });

      print('User data stored successfully in Firestore');
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
