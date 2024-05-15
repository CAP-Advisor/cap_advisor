import 'package:cloud_firestore/cloud_firestore.dart';

 /* factory Supervisor.fromMap(String id, Map<String, dynamic> map) {
    return Supervisor(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      hrId: map['hrId'] ?? '',
      studentList: List<String>.from(map['studentList'] ?? []),
    );
  }*/

 /* Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'studentList': studentList,
      'hrId': hrId,
    };
  }*/

  /*factory Supervisor.fromFirestore(DocumentSnapshot doc) {
    return Supervisor.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }*/
class SupervisorModel {
  String name;
  final String email;
  final String uid;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final List<String>? studentList;
  final String hrId;

  SupervisorModel({
    required this.name,
    required this.email,
    required this.uid,
    this.photoUrl,
    this.coverPhotoUrl,
    this.studentList,
    required this.hrId,

  });

  factory SupervisorModel.fromDocSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupervisorModel(
      name: data['name'] as String,
      email: data['email'] as String,
      uid: doc.id,
      photoUrl: data['photoUrl'] as String?,
      coverPhotoUrl: data['coverPhotoUrl'] as String?,
      hrId: data['hrId'] ?? '',
      studentList: List<String>.from(data['studentList'] ?? []),
    );
  }
}
