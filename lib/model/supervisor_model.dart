import 'package:cloud_firestore/cloud_firestore.dart';

class SupervisorModel {
  String name;
  final String email;
  final String uid;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final List<String>? studentList;

  SupervisorModel({
    required this.name,
    required this.email,
    required this.uid,
    this.photoUrl,
    this.coverPhotoUrl,
    this.studentList,
  });

  factory SupervisorModel.fromDocSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupervisorModel(
      name: data['name'] as String,
      email: data['email'] as String,
      uid: doc.id,
      photoUrl: data['photoUrl'] as String?,
      coverPhotoUrl: data['coverPhotoUrl'] as String?,
    );
  }
}
