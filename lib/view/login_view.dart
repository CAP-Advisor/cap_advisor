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

  String? emailError;
  String? passwordError;
  String? loginError;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset('assets/images/login_logo.png'),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    hintText: 'Email',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorMessage: emailError ?? '',
                    isValid: emailError == null,
                    onChanged: (value) => setState(() {
                      emailError = null;
                      loginError = null;
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          emailError = 'Please enter an Email';
                        });
                        return null;
                      }
                      if (!ValidationUtils.isValidEmail(value)) {
                        setState(() {
                          emailError = 'Please enter a valid Email';
                        });
                        return null;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(height: 30),
                  CustomTextField(
                    hintText: 'Password',
                    controller: passwordController,
                    obscureText: true,
                    errorMessage: passwordError ?? '',
                    isValid: passwordError == null,
                    onChanged: (_) => setState(() {
                      passwordError = null;
                      loginError = null;
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          passwordError = 'Please enter Password';
                        });
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 60),
                  CustomButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        viewModel.login(email, password).then((user) {
                          if (user != null) {
                            viewModel.redirectUser(context, user.userType);
                          } else {
                            setState(() {
                              loginError =
                              'Failed to login. Please check your credentials.';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loginError!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        });
                      }
                    },
                    text: 'Login',
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
}
