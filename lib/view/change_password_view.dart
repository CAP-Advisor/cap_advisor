import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/change_password_viewmodel.dart';
import '../widgets/custom_submit_button.dart';
import '../widgets/custom_text_field.dart';

class ChangePasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangePasswordViewModel>(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: Text(
              "Change Password",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 60),
                Text(
                  "Your password must be at least 8 characters and should include numbers, letters, special characters, and at least one uppercase letter.",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 50),
                CustomTextField(
                  hintText: "Enter current password",
                  controller: model.currentPasswordController,
                  onChanged: (value) => model.validateFields(),
                  errorMessage: model.currentPasswordError,
                  showError: model.currentPasswordError.isNotEmpty,
                  isValid: model.currentPasswordError.isEmpty,
                  obscureText: true,
                ),
                SizedBox(height: 40),
                CustomTextField(
                  hintText: "Enter new password",
                  controller: model.newPasswordController,
                  onChanged: (value) {
                    model.validateFields();
                  },
                  errorMessage: model.newPasswordError,
                  showError: model.newPasswordError.isNotEmpty,
                  isValid: model.newPasswordIsValid,
                  obscureText: true,
                ),
                SizedBox(height: 40),
                CustomTextField(
                  hintText: "Re-enter new password",
                  controller: model.retypeNewPasswordController,
                  onChanged: (value) {
                    model.validateFields();
                  },
                  errorMessage: model.retypePasswordError,
                  showError: model.retypePasswordError.isNotEmpty,
                  isValid: model.retypePasswordIsValid,
                  obscureText: true,
                ),
                SizedBox(height: 70),
                Center(
                  child: CustomButton(
                    onPressed: () async {
                      await model.changePassword(context);
                    },
                    text: "Submit",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
