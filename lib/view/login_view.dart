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

  bool rememberMe = false;
  bool isSubmitted = false;
  bool isValidEmail = false;
  bool isValidPassword = false;
  bool isValidForm = false;
  bool emailExists = false;
  String? emailError;
  String? passwordError;
  String? loginError;

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
  }

  void _loadStoredCredentials() async {
    final credentials = await viewModel.getStoredCredentials();
    setState(() {
      emailController.text = credentials['email'] ?? '';
      passwordController.text = credentials['password'] ?? '';
      rememberMe =
          credentials['email'] != null && credentials['password'] != null;
    });
  }

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
                        setState(() {
                          isValidEmail = value.isNotEmpty &&
                              ValidationUtils.isValidEmail(value);
                          isValidForm = validateForm();
                        });
                      },
                      errorMessage: "Please enter a valid email",
                      isValid: isValidEmail,
                      showError: isSubmitted && !isValidEmail,
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
                        setState(() {
                          isValidPassword = value.isNotEmpty &&
                              ValidationUtils.isValidPassword(value);
                          isValidForm = validateForm();
                        });
                      },
                      errorMessage: "Please enter a valid password",
                      isValid: isValidPassword,
                      showError: isSubmitted && !isValidPassword,
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: Text("Remember Me"),
                    value: rememberMe,
                    onChanged: (newValue) {
                      setState(() {
                        rememberMe = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 60),
                  CustomButton(
                    onPressed: () async {
                      setState(() {
                        isSubmitted = true;
                        isValidEmail = emailController.text.isNotEmpty &&
                            ValidationUtils.isValidEmail(emailController.text);
                        isValidPassword = passwordController.text.isNotEmpty &&
                            ValidationUtils.isValidPassword(
                                passwordController.text);
                        isValidForm = isValidEmail && isValidPassword;
                      });
                      if (isValidForm) {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        viewModel
                            .login(email, password, rememberMe)
                            .then((user) {
                          if (user != null) {
                            viewModel.redirectUser(context, user.userType);
                          } else {
                            setState(() {
                              loginError =
                                  'Failed to login. Please check your credentials.';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
