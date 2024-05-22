import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String name;
  final String email;
  final String major;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final String summary;
  final List<String> skills;
  final List<String> experience;
  final String github;
  final String address;
  double gpa;
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
    required this.address,
    required this.additionalInfo,
    required this.uid,
    this.photoUrl,
    required this.gpa,
    this.coverPhotoUrl,
    required this.experience,
    required this.github,
    required this.skills,
    required this.summary,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Student(
      name: data['name'] ?? 'No name provided',
      email: data['email'] ?? 'No email provided',
      major: data['major'] ?? 'CAP',
      gpa: (data['gpa'] is num)
          ? data['gpa'].toDouble()
          : double.tryParse(data['gpa'].toString()) ?? 0.0,
      summary: data['summary'] ?? '',
      address: data['address'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      experience: List<String>.from(data['experience'] ?? []),
      github: data['github'] ?? '',
      additionalInfo: data['additionalInfo'] ?? 'Non-specialist',
      uid: doc.id,
      //skills: data['skills'] != null ? List<String>.from(data['skills'] as List<dynamic>) : null,
      photoUrl: data['photoUrl'] as String?,
      coverPhotoUrl: data['coverPhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'major': major,
      'photoUrl': photoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'additionalInfo': additionalInfo,
      'summary': summary,
      'skills': skills,
      'experience': experience,
      'github': github,
      'address': address,
      'gpa': gpa,
      'uid': uid,
      'isApproved': isApproved
    };
  }
}