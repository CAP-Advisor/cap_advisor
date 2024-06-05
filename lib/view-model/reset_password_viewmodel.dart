import 'package:cap_advisor/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordViewModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool showWarning = false;
  String email = '';

  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';

  void validateAndSubmit(BuildContext context) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      resetPassword(context);
    } else {
      showWarning = true;
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password reset email sent.'),
            backgroundColor: successColor),
      );
    } catch (error) {
      String errorMessage = 'An error occurred';
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (error.code == 'invalid-email') {
          errorMessage = 'Invalid email entered.';
        } else if (error.code == 'too-many-requests') {
          errorMessage = 'Too many requests. Try again later.';
        } else {
          errorMessage = error.message ?? 'Unknown error occurred';
        }
      } else {
        errorMessage = 'Unknown error occurred';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: errorColor),
      );
    }
  }

  String? validateEmail(String? value) {
    if (value == null || !RegExp(emailPattern).hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }
}
