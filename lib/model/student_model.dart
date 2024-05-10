import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String name;
  final String email;

  Student({required this.name, required this.email});

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Student(
      name: data['name'] ?? 'No name provided',
      email: data['email'] ?? 'No email provided',
    );
  }
}
