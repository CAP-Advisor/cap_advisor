
import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';
import '../view-model/login_viewmodel.dart';
import 'reset_password_view.dart';
import 'sign_up_view.dart';

class LoginView extends StatefulWidget{
  @override
  _LoginViewState createState()=>_LoginViewState();
}
class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginViewModel viewModel = LoginViewModel();
  final _formKey =GlobalKey<FormState>();

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
                emailField(),
                if(emailError!=null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0,left: 30.0),
                      child: Text(
                        emailError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                const SizedBox(height: 30),
                passwordField(),
                if(passwordError!=null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0,left: 30.0),
                      child: Text(
                        passwordError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                const SizedBox(height: 60),
                loginButton(context),
                const SizedBox(height: 20),
                forgotPasswordButton(context),
                const SizedBox(height: 10),
                signUpButton(context),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }
  Widget emailField() {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email',
            hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
            border: InputBorder.none,
          ),
          validator: (value){
            if(value==null || value.isEmpty){
              setState(() {
                emailError = 'Please enter an Email';
              });
              return null;
            }
    // Check email format
            if (!ValidationUtils.isValidEmail(value)) {
              setState(() {
                emailError = 'Please enter a valid Email';
              });
              return null;            }
            },
          onChanged: (_)=> setState(() {
            emailError = null;
            loginError = null;
          }),
        ),
      ),
    );
  }

  Widget passwordField() {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
            border: InputBorder.none,
          ),
          validator: (value){
            if(value==null|| value.isEmpty){
              setState(() {
                passwordError = 'Please enter Password';
              });            }
            return null;
          },
          onChanged: (_)=> setState(() {
            passwordError = null;
            loginError = null;
          }),        ),
      ),
    );
  }

  Widget loginButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if(_formKey.currentState!.validate()) {
            String email = emailController.text.trim();
            String password = passwordController.text.trim();
            viewModel.login(email, password).then((success) {
              if (success) {
                print("login successful");

                redirectUser(context, viewModel.userType);
              }
              else {
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF427D9D),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Login',
          style: TextStyle(fontSize: 23, color: Colors.white),
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
void redirectUser(BuildContext context, String userType) {
  switch (userType) {
    case 'HR':
      Navigator.pushReplacementNamed(context, '/HR');
      break;
    case 'Supervisor':
      Navigator.pushReplacementNamed(context, '/Supervisor');
      break;
    case 'Instructor':
      Navigator.pushReplacementNamed(context, '/Instructor');
      break;
    case 'Student':
      Navigator.pushReplacementNamed(context, '/Student');
      break;
    default:
    // Handle unknown user type
  }
}