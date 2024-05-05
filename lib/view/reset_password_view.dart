import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../view-model/reset_password_viewmodel.dart';

class ResetPasswordPage extends StatelessWidget {
  final ResetPasswordViewModel viewModel = ResetPasswordViewModel();

  ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',  // Tooltip added for better accessibility
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: viewModel.formKey,
          child: SingleChildScrollView(  // Use SingleChildScrollView to avoid overflow when keyboard appears
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20),
                Text(
                  'Enter the email address associated with your account and we will send an email with instructions to reset your password',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: viewModel.validateEmail,
                  onSaved: (value) => viewModel.email = value!,
                ),
                SizedBox(height: 20),
                Center( // Wrap ElevatedButton with Center widget
                  child: ElevatedButton(
                    onPressed: () => viewModel.validateAndSubmit(context),
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Color(0xFF427D9D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(138, 55), // Adjust button size
                      padding: EdgeInsets.zero,
                      textStyle: TextStyle(letterSpacing: 1.2),
                    ),
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run the app
  runApp(MaterialApp(home: ResetPasswordPage()));
}