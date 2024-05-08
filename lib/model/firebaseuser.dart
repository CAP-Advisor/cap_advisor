import 'package:cloud_firestore/cloud_firestore.dart';

class firebaseuser
{
  late final String email;
  late final String password;
  late final String Uid;
  final String userType;
  firebaseuser.fromMap(Map<String, dynamic> userdata)
      : email = userdata["email"],
        password = userdata["password"],
        Uid = userdata["Uid"],
  userType=userdata["userType"];
  firebaseuser.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>>doc)
      : Uid = doc.data()!["Uid"],
        email = doc.data()!["email"],
        password = doc.data()!["password"],
        userType = doc.data()!["userType"];
}