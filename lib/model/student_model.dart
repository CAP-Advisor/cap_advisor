import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String name;
  final String email;
  final String major;
  final String additionalInfo;
  final String uid;
  bool isApproved = false;
  final double? gpa; // Make GPA nullable
  final String address;
  final List<String>? skills; // Make skills nullable

  Student({
    required this.name,
    required this.email,
    required this.major,
    required this.additionalInfo,
    required this.uid,
    this.gpa,
    required this.address,
    this.skills,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Student(
      name: data['name'] ?? 'No name provided',
      email: data['email'] ?? 'No email provided',
      major: data['major'] ?? 'CAP',
      additionalInfo: data['additionalInfo'] ?? 'Non-specialist',
      uid: doc.id,
      gpa: data['gpa'] is String ? double.tryParse(data['gpa']) : data['gpa']?.toDouble(),
      address: data['address'] ?? '',
      skills: data['skills'] != null ? List<String>.from(data['skills'] as List<dynamic>) : null,
    );
  }


}