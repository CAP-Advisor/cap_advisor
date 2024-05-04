import 'package:flutter/material.dart';
import 'reset_password_view.dart';
import 'sign_up_view.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset('assets/images/login_logo.png'),
                ),
                const SizedBox(height: 40),
                usernameField(),
                const SizedBox(height: 30),
                passwordField(),
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
    );
  }

  Widget usernameField() {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Username',
            hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
            border: InputBorder.none,
          ),
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
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
            border: InputBorder.none,
            suffixIcon: Icon(Icons.remove_red_eye),
          ),
        ),
      ),
    );
  }

  Widget loginButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          null;
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
