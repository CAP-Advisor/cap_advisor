import 'package:flutter/material.dart';
import '../model/sign_up_model.dart';
import '../service/firebase_service.dart';

class SignUpViewModel {
  SignUpModel model = SignUpModel();
  bool userTypeSelected = false;
  bool emailExists = false;

  final FirebaseService _firebaseService = FirebaseService();

  String? get password => model.password;

  void setUserType(String? userType) {
    model.userType = userType;
    userTypeSelected =
        userType != null && userType.isNotEmpty;
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
      emailExists = await _firebaseService.checkEmailExists(model.email!);
      if (!emailExists) {
        await _firebaseService.storeUserData(
            model.userType!,
            model.name!,
            model.username!,
            model.email!,
            model.password!
        );
        return true;
      }
    } else {
      print("Form validation failed");
    }
    return false;
  }

  bool _validateForm() {
    if (!userTypeSelected) return false; // Check if user type is selected
    if (model.name == null || model.name!.isEmpty) return false;
    if (model.username == null || model.username!.isEmpty) return false;
    if (model.email == null || model.email!.isEmpty) return false;
    if (!_isValidEmail(model.email!)) return false;
    if (model.password == null || model.password!.isEmpty) return false;
    if (model.confirmPassword == null || model.confirmPassword!.isEmpty)
      return false;
    if (model.password != model.confirmPassword)
      return false; // Fix password confirmation check
    return true;
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
