import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';  // Correct package import

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to check if an email exists in the Firestore database
  Future<bool> emailExists(String email) async {
    try {
      // Query the users collection to check if the email exists
      QuerySnapshot querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (kDebugMode) {
        print("Query result size: ${querySnapshot.size}");
      } // Debug output to help in development mode
      return querySnapshot.docs.isNotEmpty; // Return true if email exists, otherwise false
    } catch (error) {
      if (kDebugMode) {
        print('Error checking email in database: $error');
      }
      return false; // Handle the error appropriately and return false
    }
  }
}
