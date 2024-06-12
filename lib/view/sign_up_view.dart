import 'package:cap_advisor/resources/colors.dart';
import 'package:flutter/material.dart';
import '../view-model/sign_up_viewmodel.dart';
import 'dart:core';
import '../utils/validation_utils.dart';
import '../widgets/custom_dropdown_button.dart';
import '../widgets/custom_submit_button.dart';
import '../widgets/custom_text_field.dart';

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final SignUpViewModel viewModel = SignUpViewModel();
  bool isValidForm = false;
  bool isSubmitted = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isValidName = false;
  bool isValidUsername = false;
  bool isValidEmail = false;
  bool isValidPassword = false;
  bool isValidConfirmPassword = false;
  bool isValidUserType = false;
  bool emailExists = false;

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: IconThemeData(color: secondaryColor),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "CREATE ACCOUNT",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: hintTextColor,
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: 390,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdownButton(
                          items: ["HR", "Student", "Supervisor", "Instructor"],
                          value: viewModel
                              .userType,
                          hintText: "User Type",
                          onChanged: (newValue) {
                            viewModel.setUserType(newValue);
                            setState(() {
                              isValidUserType = newValue != null;
                              isValidForm = validateForm();
                            });
                          },
                          errorMessage: "Please select a user type",
                          isValid: isValidUserType,
                          showError: isSubmitted,
                        ),
                        SizedBox(height: 35),
                        CustomTextField(
                          hintText: "Name",
                          controller: nameController,
                          onChanged: (value) {
                            viewModel.setName(value);
                            setState(() {
                              isValidName = value.isNotEmpty;
                              isValidForm = validateForm();
                            });
                          },
                          errorMessage: "Please enter your name",
                          isValid: isValidName,
                          showError: isSubmitted,
                        ),
                        SizedBox(height: 35),
                        CustomTextField(
                          hintText: "Username",
                          controller: usernameController,
                          onChanged: (value) {
                            viewModel.setUsername(value);
                            setState(() {
                              isValidUsername = value.isNotEmpty;
                              isValidForm = validateForm();
                            });
                          },
                          errorMessage: "Please enter your username",
                          isValid: isValidUsername,
                          showError: isSubmitted,
                        ),
                        SizedBox(height: 35),
                        CustomTextField(
                          hintText: "Email",
                          controller: emailController,
                          onChanged: (value) {
                            viewModel.setEmail(value);
                            setState(() {
                              isValidEmail = value.isNotEmpty &&
                                  ValidationUtils.isValidEmail(value);
                              isValidForm = validateForm();
                            });
                          },
                          errorMessage: "Please enter a valid email",
                          isValid: isValidEmail,
                          showError: isSubmitted,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Visibility(
                          visible: emailExists && isSubmitted,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "Error: Email already exists",
                              style: TextStyle(color: errorColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 35),
                        CustomTextField(
                          hintText: "Password",
                          controller: passwordController,
                          onChanged: (value) {
                            viewModel.setPassword(value);
                            setState(() {
                              isValidPassword = value.isNotEmpty &&
                                  ValidationUtils.isValidPassword(value);
                              isValidForm = validateForm();
                            });
                          },
                          errorMessage: "Please enter a valid password",
                          isValid: isValidPassword,
                          showError: isSubmitted,
                          obscureText: true,
                        ),
                        SizedBox(height: 35),
                        CustomTextField(
                          hintText: "Re-enter password",
                          controller: confirmPasswordController,
                          onChanged: (value) {
                            viewModel.setConfirmPassword(value);
                            setState(() {
                              isValidConfirmPassword = value.isNotEmpty;
                              isValidForm = validateForm();
                            });
                          },
                          errorMessage: "Please re-enter your password",
                          isValid: isValidConfirmPassword,
                          showError: isSubmitted,
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 87),
                  CustomButton(
                    onPressed: () async {
                      setState(() {
                        isSubmitted = true;
                        emailExists = false;
                      });
                      if (isValidForm) {
                        bool accountCreated =
                            await viewModel.submitForm(context);
                        setState(() {
                          if (viewModel.emailExists) {
                            emailExists = true;
                          }
                          if (accountCreated) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Account created successfully!'),
                            ));
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Failed to create account. Please try again.'),
                            ));
                          }
                        });
                      }
                    },
                    text: "Submit",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool validateForm() {
    return isValidUserType &&
        isValidName &&
        isValidUsername &&
        isValidEmail &&
        isValidPassword &&
        isValidConfirmPassword;
  }
}
