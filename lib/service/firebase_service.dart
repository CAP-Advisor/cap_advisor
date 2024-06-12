import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/custom_exception.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
      String uid) async {
    return await _firestore.collection('Users').doc(uid).get();
  }

  Future<String?> generateCustomToken(String uid) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? customToken = await user.getIdToken(true);
        print('Generated Custom Token: $customToken');
        return customToken;
      } else {
        throw CustomException('User is not signed in.');
      }
    } catch (e) {
      throw CustomException('Error generating custom token: $e');
    }
  }

  Future<bool> verifyCustomToken(String customToken) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
      User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          print('Custom token verified successfully');
          return true;
        } else {
          throw CustomException(
              'Error verifying custom token: User not authenticated');
        }
      } else {
        throw CustomException(
            'Error verifying custom token: User not authenticated');
      }
    } catch (e) {
      throw CustomException('Error verifying custom token: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserDataFromToken(String token) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw CustomException('User not authenticated');
      }

      DocumentSnapshot snapshot =
          await _firestore.collection('Users').doc(user.uid).get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw CustomException('User data not found');
      }
    } catch (e) {
      throw CustomException('Error getting user data from token: $e');
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
      throw CustomException('Error signing in: $e');
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
      throw CustomException('Error checking email existence: $e');
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
      throw CustomException('Error storing user data: $e');
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
        throw CustomException('User not found');
      }
    } catch (e) {
      throw CustomException('Error getting hashed password: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String? email) async {
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
          throw CustomException('User type is null for user: $email');
        }
      } else {
        throw CustomException('No user data found for email: $email');
      }
    } catch (e) {
      throw CustomException('Error getting user data: $e');
    }
  }

  Future<String?> getUserRole() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw CustomException('User not authenticated');
      }
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['userType'];
      } else {
        throw CustomException('User role not found');
      }
    } catch (e) {
      throw CustomException("Error getting user role: $e");
    }
  }
}

Future<bool> verifyIdToken(String idToken) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCustomToken(idToken);
    User? user = userCredential.user;
    if (user != null) {
      return true;
    } else {
      throw CustomException('User not authenticated');
    }
  } catch (e) {
    throw CustomException('Error verifying ID token: $e');
  }
}
