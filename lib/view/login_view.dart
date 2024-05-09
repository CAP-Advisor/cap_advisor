import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';
import '../view-model/login_viewmodel.dart';
import '../widgets/custom_submit_button.dart';
import '../widgets/custom_text_field.dart';
import 'reset_password_view.dart';
import 'sign_up_view.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginViewModel viewModel = LoginViewModel();
  final _formKey = GlobalKey<FormState>();

  bool isSubmitted = false;
  bool isValidEmail = false;
  bool isValidPassword = false;
  bool isValidForm = false;
  bool emailExists = false;
  String? emailError;
  String? passwordError;
  String? loginError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Image.asset('assets/images/login_logo.png'),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 390,
                    child: CustomTextField(
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
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 390,
                    child: CustomTextField(
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
                  ),
                  const SizedBox(height: 60),
                  CustomButton(
                    onPressed: () async {
                      setState(() {
                        isSubmitted = true;
                        emailExists = false;
                      });
                      if (isValidForm) {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        viewModel.login(email, password).then((user) {
                          if (user != null) {
                            viewModel.redirectUser(
                                context, user.userType); // Redirect based on userType
                          } else {
                            setState(() {
                              loginError =
                              'Failed to login. Please check your credentials.';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loginError!),
                                  backgroundColor: Colors.red,
                                ));
                          }
                        });
                      }
                    },
                    text: "Submit",
                  ),
                  const SizedBox(height: 20),
                  forgotPasswordButton(context),
                  const SizedBox(height: 10),
                  signUpButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget forgotPasswordButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordView()),
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(color: Color(0xFF427D9D)),
        ),
      ),
    );
  }

  Widget signUpButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpView()),
          );
        },
        child: const Text(
          'Do not have an account? Sign up',
          style: TextStyle(color: Color(0xFF427D9D)),
        ),
      ),
    );
  }

  bool validateForm() {
    return isValidEmail && isValidPassword;
  }
}