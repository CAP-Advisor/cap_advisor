import 'package:cloud_firestore/cloud_firestore.dart';

class Supervisor {
  final String id;
  final String name;
  final String email;
  List<String>? studentList;
  final String hrId;

  Supervisor({
    required this.id,
    required this.name,
    required this.email,
    required this.hrId,
    this.studentList,
  });

  factory Supervisor.fromMap(String id, Map<String, dynamic> map) {
    return Supervisor(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      hrId: map['hrId'] ?? '',
      studentList: List<String>.from(map['studentList'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'studentList': studentList,
      'hrId': hrId,
    };
  }

  factory Supervisor.fromFirestore(DocumentSnapshot doc) {
    return Supervisor.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
