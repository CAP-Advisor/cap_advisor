import 'package:cloud_firestore/cloud_firestore.dart';

class Instructor {
  final String name;
  final String email;
  final String? photoUrl;
  final String? coverPhotoUrl;

  Instructor({
    required this.name,
    required this.email,
    this.photoUrl,
    this.coverPhotoUrl,
  });

  factory Instructor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Instructor(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      coverPhotoUrl: data['coverPhotoUrl'],
    );
  }
}
