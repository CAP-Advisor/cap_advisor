import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  String id;
  String name;
  String email;
  String description;
  List<String> skills;
  String title;
  String hrId;

  Job({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.skills,
    required this.title,
    required this.hrId
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Job(
      id: doc.id,
      name: data['name'] ?? 'No name provided',
      email: data['email'] ?? 'No email provided',
      description: data['description'] ?? 'No description provided',
      skills: List<String>.from(data['skills'] ?? []),
      title: data['title'] ?? 'No title provided',
      hrId:data['hrId'] ?? 'No hr id',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'description': description,
      'skills': skills,
      'title': title
    };
  }
}
