import 'package:cap_advisor/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: 450,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 60),
                Image.asset(
                  'assets/images/login_logo.png',
                  height: 358,
                  width: 324,
                ),
                SizedBox(height: 117),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(225, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: primaryColor,
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/SignUp');
                      },
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size(225, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "Join us!",
                        style: TextStyle(
                          color: primaryColor,
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
                ,
                SizedBox(height: 120),

              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget logoutBtn(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginView()));
        },
        child: const Text(
          'Logout',
          style: TextStyle(color: primaryColor),
        ),
      ),
    );
  }
}
