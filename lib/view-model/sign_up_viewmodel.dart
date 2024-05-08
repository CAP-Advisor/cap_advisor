import 'package:cap_advisor/utils/validation_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/sign_up_model.dart';
import '../service/firebase_service.dart';

class SignUpViewModel {
  SignUpModel model = SignUpModel();
  bool userTypeSelected = false;
  bool emailExists = false;

  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get password => model.password;
  String? get userType => model.userType;

  void setUserType(String? userType) {
    model.userType = userType;
    userTypeSelected = userType != null && userType.isNotEmpty;
  }

  void setName(String? name) {
    model.name = name;
  }

  void setUsername(String? username) {
    model.username = username;
  }

  void setEmail(String? email) {
    model.email = email;
  }

  void setPassword(String? password) {
    model.password = password;
  }

  void setConfirmPassword(String? confirmPassword) {
    model.confirmPassword = confirmPassword;
  }

  Future<bool> submitForm(BuildContext context) async {
    if (_validateForm()) {
      try {
        emailExists = await _firebaseService.checkEmailExists(model.email!);
        if (emailExists) {
          return false;
        }
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: model.email!,
          password: model.password!,
        );
        await _firebaseService.storeUserData(
          model.userType!,
          model.name!,
          model.username!,
          model.email!,
          model.password!,
          userCredential.user!.uid,
        );
        return true;
      } catch (e) {
        print("Error creating user account: $e");
        return false;
      }
    } else {
      print("Form validation failed");
    }
    return false;
  }

  bool _validateForm() {
    if (!userTypeSelected) return false;
    if (model.name == null || model.name!.isEmpty) return false;
    if (model.username == null || model.username!.isEmpty) return false;
    if (model.email == null || model.email!.isEmpty) return false;
    if (!ValidationUtils.isValidEmail(model.email!)) return false;
    if (model.password == null || model.password!.isEmpty) return false;
    if (model.confirmPassword == null || model.confirmPassword!.isEmpty)
      return false;
    if (model.password != model.confirmPassword) return false;
    return true;
  }
}
