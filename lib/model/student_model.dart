import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String name;
  final String email; // Add email field

  Student(
      {required this.name,
      required this.email}); // Include email in the constructor

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Student(
      name: data['name'] ?? 'No name provided',
      email: data['email'] ?? 'No email provided', // Default value if not found
    );
  }
}
