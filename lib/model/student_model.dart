  import 'package:cloud_firestore/cloud_firestore.dart';

  class Student {
    final String id;
    final String name;
    final String email;
    bool isApproved = false;

    Student({
      required this.id,
      required this.name,
      required this.email,
    });

    factory Student.fromFirestore(DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return Student(
        id: doc.id,
        name: data['name'] ?? 'No name provided',
        email: data['email'] ?? 'No email provided',
      );
    }
  }
