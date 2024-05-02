import 'package:flutter/material.dart';
import 'reset_password_view.dart';
import 'sign_up_view.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              children: <Widget>[
                Image.asset('assets/images/login_logo.png'),
                const SizedBox(height: 40),
                usernameField(_usernameController),
                const SizedBox(height: 30),
                passwordField(_passwordController),
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

  Widget usernameField(TextEditingController controller) {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Username',
          hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget passwordField(TextEditingController controller) {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Login logic here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF427D9D),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      ),
      child: const Text(
        'Login',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget forgotPasswordButton(BuildContext context) {
    return TextButton(
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
    );
  }

  Widget signUpButton(BuildContext context) {
    return TextButton(
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
    );
  }
}
