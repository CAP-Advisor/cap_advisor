import 'package:cap_advisor/model/firebaseuser.dart';
import 'package:cap_advisor/utils/role_factory.dart';
import 'package:cap_advisor/utils/validation_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service/firebase_service.dart';
import '../view/login_view.dart';

class LoginViewModel {
  final FirebaseService _firebaseService = FirebaseService();
   String userType = '';
   final storage = const FlutterSecureStorage();



  void redirectUser(BuildContext context, String? userType) {
    var requestedView=roleFactory(userType);
    if(requestedView!=null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => requestedView));
    }

      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown user type')),
        );
        // Redirect to login page for unknown user type
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
    }
  }

  Future<FireBaseUser?> login(String email, String password) async {
    try {
      if (!ValidationUtils.isValidEmail(email)) {
        return null;
      }

      bool isLoginSuccessful = await _firebaseService.signInWithEmailAndPassword(email, password);
      if (!isLoginSuccessful) {
        print('Authentication failed');
        return null;
      }

      User? user = FirebaseAuth.instance.currentUser;
      FireBaseUser userObj = FireBaseUser();
      if (user != null) {
        String? token = await user.getIdToken();
        if (token != null) {
          print('Login Successful! Token: $token');

          Map<String, dynamic>? userdata=await _firebaseService.getUserData(email);
          userObj=FireBaseUser.fromMap(userdata!);
          // await storage.write(key: 'session_token', value: token);
          return userObj;
        }
      }

      return userObj;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }
}
