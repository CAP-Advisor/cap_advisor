import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/validation_utils.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController retypeNewPasswordController =
      TextEditingController();

  bool currentPasswordIsValid = true;
  bool newPasswordIsValid = true;
  bool retypePasswordIsValid = true;
  String currentPasswordError = '';
  String newPasswordError = '';
  String retypePasswordError = '';

  void validateFields() {
    currentPasswordIsValid = currentPasswordController.text.isNotEmpty;
    newPasswordIsValid = newPasswordController.text.isNotEmpty &&
        ValidationUtils.isValidPassword(newPasswordController.text);
    retypePasswordIsValid =
        newPasswordController.text == retypeNewPasswordController.text;

    currentPasswordError =
        currentPasswordIsValid ? '' : "Current password is required.";
    newPasswordError =
        newPasswordIsValid ? '' : "New password must meet all criteria.";
    retypePasswordError =
        retypePasswordIsValid ? '' : "Passwords do not match.";

    notifyListeners();
  }

  Future<void> changePassword(BuildContext context) async {
    User? user = _auth.currentUser;
    validateFields();

    if (currentPasswordIsValid && newPasswordIsValid && retypePasswordIsValid) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPasswordController.text);
        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        handleFirebaseAuthError(e);
      } catch (e) {
        currentPasswordError = "An unexpected error occurred: $e";
        notifyListeners();
      }
    }
  }

  void handleFirebaseAuthError(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      newPasswordError = "The password is too weak.";
    } else if (e.code == 'wrong-password') {
      currentPasswordError = "Your current password is incorrect.";
    } else {
      currentPasswordError = "An error occurred: ${e.message}";
    }
    notifyListeners();
  }
}
