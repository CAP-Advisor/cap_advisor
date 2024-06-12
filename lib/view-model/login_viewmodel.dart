import 'package:cap_advisor/model/firebaseuser.dart';
import 'package:cap_advisor/model/login_model.dart';
import 'package:cap_advisor/utils/role_factory.dart';
import 'package:cap_advisor/utils/validation_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../exceptions/custom_exception.dart';
import '../service/firebase_service.dart';
import '../view/login_view.dart';

class LoginViewModel {
  LoginModel model = LoginModel();
  final FirebaseService _firebaseService = FirebaseService();
  String userType = '';
  final storage = const FlutterSecureStorage();

  void redirectUser(BuildContext context, String? userType) {
    var requestedView = roleFactory(userType);
    if (requestedView != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => requestedView));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown user type')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
  }

  Future<FireBaseUser?> login(
      String email, String password, bool rememberMe) async {
    try {
      if (!ValidationUtils.isValidEmail(email)) {
        return null;
      }

      bool isLoginSuccessful =
          await _firebaseService.signInWithEmailAndPassword(email, password);
      if (!isLoginSuccessful) {
        throw CustomException('Authentication failed');
      }

      User? user = FirebaseAuth.instance.currentUser;
      FireBaseUser userObj = FireBaseUser();
      if (user != null) {
        String? token = await user.getIdToken();
        if (token != null) {
          print('Login Successful! Token: $token');

          Map<String, dynamic>? userdata =
              await _firebaseService.getUserData(email);
          userObj = FireBaseUser.fromMap(userdata!);
          if (rememberMe) {
            await storage.write(key: 'email', value: email);
            await storage.write(key: 'password', value: password);
          } else {
            await storage.delete(key: 'email');
            await storage.delete(key: 'password');
          }
          return userObj;
        } else {
          throw CustomException('Failed to retrieve token');
        }
      } else {
        throw CustomException('User not found');
      }
    } catch (e) {
      print('Error during login: $e');
      throw CustomException('Error during login: $e');
    }
  }

  Future<Map<String, String?>> getStoredCredentials() async {
    String? email = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  void setEmail(String? email) {
    model.email = email;
  }

  void setPassword(String? password) {
    model.password = password;
  }
}
