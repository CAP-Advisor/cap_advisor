  import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String name;
  final String email;
  final String major;
  final String additionalInfo;
  final String uid;
  bool isApproved = false;

  Student({
    required this.name,
    required this.email,
    required this.major,
    required this.additionalInfo,
    required this.uid,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Student(
      name: data['name'] ?? 'No name provided',
      email: data['email'] ?? 'No email provided',
      major: data['major'] ?? 'CAP',
      additionalInfo: data['additionalInfo'] ?? 'Non-specialist',
      uid: doc.id,
    );
  }
}