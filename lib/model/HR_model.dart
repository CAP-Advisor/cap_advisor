import 'package:cloud_firestore/cloud_firestore.dart';

class HR {
  String companyName;
  String email;
  List<String>? jobsList;
  String name;
  final String uid;
  final String? photoUrl;
  final String? coverPhotoUrl;

  HR({
    required this.name,
    required this.companyName,
    required this.email,
    this.jobsList,
    required this.uid,
    this.photoUrl,
    this.coverPhotoUrl,
  });

  factory HR.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return HR(
      name: data['name'] ?? 'No name provided',
      email: data['email'] ?? 'No email provided',
      companyName: data['companyName'] ?? '',
      uid: doc.id,
      photoUrl: data['photoUrl'] as String?,
      coverPhotoUrl: data['coverPhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'companyName': companyName,
    };
  }
}
