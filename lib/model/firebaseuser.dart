import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseUser
{
  String? email;
  String? password;
  String? Uid;
   String? userType;

  FireBaseUser({
    this.email,
    this.password,
    this.Uid,
    this.userType,
  });
  FireBaseUser.fromMap(Map<String, dynamic> userdata)
      : email = userdata["email"],
        password = userdata["password"],
        Uid = userdata["Uid"],
  userType=userdata["userType"];
  FireBaseUser.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>>doc)
      : Uid = doc.data()!["Uid"],
        email = doc.data()!["email"],
        password = doc.data()!["password"],
        userType = doc.data()!["userType"];
}