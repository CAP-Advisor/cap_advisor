import 'package:flutter/material.dart';
import '../view-model/sign_up_viewmodel.dart';
import 'dart:core';
import '../utils/validation_utils.dart';

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
          iconTheme: IconThemeData(color: Color(0xFF164863)),
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
                      color: Color(0xFF9A9A9A),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: 390,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: "User Type",
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Color(0xFFF5F8F9),
                            filled: true,
                            hintStyle: TextStyle(
                              color: Color(0xFF9A9A9A),
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                          ),
                          items: ["HR", "Student", "Supervisor", "Instructor"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            viewModel.setUserType(newValue);
                            setState(() {
                              isValidUserType = newValue != null;
                              isValidForm = validateForm();
                            });
                          },
                        ),
                        SizedBox(height: isSubmitted && !isValidUserType ? 8 : 0),
                        Visibility(
                          visible: isSubmitted && !isValidUserType,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "Please select a user type",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(height: 35),
                        buildTextField("Name", nameController, (value) {
                          viewModel.setName(value);
                          setState(() {
                            isValidName = value.isNotEmpty;
                            isValidForm = validateForm();
                          });
                        }, "Please enter your name", isValidName),
                        SizedBox(height: 35),
                        buildTextField("Username", usernameController, (value) {
                          viewModel.setUsername(value);
                          setState(() {
                            isValidUsername = value.isNotEmpty;
                            isValidForm = validateForm();
                          });
                        }, "Please enter your username", isValidUsername),
                        SizedBox(height: 35),
                        buildTextField("Email", emailController, (value) {
                          viewModel.setEmail(value);
                          setState(() {
                            isValidEmail = value.isNotEmpty && ValidationUtils.isValidEmail(value);
                            isValidForm = validateForm();
                          });
                        }, "Please enter a valid email", isValidEmail, keyboardType: TextInputType.emailAddress),
                        Visibility(
                          visible: emailExists && isSubmitted,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "Error: Email already exists",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(height: 35),
                        buildTextField("Password", passwordController, (value) {
                          viewModel.setPassword(value);
                          setState(() {
                            isValidPassword = value.isNotEmpty && ValidationUtils.isValidPassword(value);
                            isValidForm = validateForm();
                          });
                        }, "Please enter a valid password", isValidPassword, obscureText: true),
                        SizedBox(height: 35),
                        buildTextField("Re-enter password", confirmPasswordController, (value) {
                          viewModel.setConfirmPassword(value);
                          setState(() {
                            isValidConfirmPassword = value.isNotEmpty;
                            isValidForm = validateForm();
                          });
                        }, "Please re-enter your password", isValidConfirmPassword, obscureText: true),
                      ],
                    ),
                  ),
                  SizedBox(height: 87),
                  SizedBox(
                    width: 138,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isSubmitted = true;
                          emailExists = false;
                        });
                        if (isValidForm) {
                          bool accountCreated = await viewModel.submitForm(context);
                          setState(() {
                            if (viewModel.emailExists) {
                              emailExists = true;
                            }
                            if (accountCreated) {
                              // Account creation successful
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Account created successfully!'),
                              ));
                              Navigator.pushReplacementNamed(context, '/login');
                            } else {
                              // Account creation failed
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Failed to create account. Please try again.'),
                              ));
                            }
                          });
                        }
                      },

                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF427D9D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, TextEditingController controller, Function(String) onChanged, String errorMessage, bool isValid, {TextInputType? keyboardType, bool obscureText = false}) {
    String? password;
    String? confirmPassword;
    if (controller == passwordController) {
      password = controller.text;
    } else if (controller == confirmPasswordController) {
      confirmPassword = controller.text;
    }

    String? passwordErrorMessage;
    if (isSubmitted) {
      if (controller == confirmPasswordController && confirmPassword != password) {
        passwordErrorMessage = "Passwords don't match";
      } else if ((controller == passwordController || controller == confirmPasswordController) && password != null && password.isEmpty) {
        passwordErrorMessage = "Please enter a password";
      } else if ((controller == passwordController || controller == confirmPasswordController) && password != null && password.length < 8) {
        passwordErrorMessage = "Password should contain at least 8 characters";
      }
    }

    if (passwordController.text == confirmPasswordController.text && passwordErrorMessage == "Passwords don't match") {
      passwordErrorMessage = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            fillColor: Color(0xFFF5F8F9),
            filled: true,
            hintStyle: TextStyle(
              color: Color(0xFF9A9A9A),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: (isSubmitted && isValid) || passwordErrorMessage == null ? 0 : 8),
        Visibility(
          visible: isSubmitted && !isValid || passwordErrorMessage != null,
          child: Padding(
            padding: EdgeInsets.only(top: (isSubmitted && isValid) ? 0 : 8),
            child: Text(
              passwordErrorMessage ?? errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
  bool validateForm() {
    return isValidUserType && isValidName && isValidUsername && isValidEmail && isValidPassword && isValidConfirmPassword;
  }
}
