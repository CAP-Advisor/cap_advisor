import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/firebase_service.dart';
import '../view/HR_view.dart';
import '../view/change_password_view.dart';
import '../view/instructor_view.dart';
import '../view/login_view.dart';
import '../view/student_view.dart';
import '../view/supervisor_view.dart';

class MenuViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  String? userRole;
  User? currentUser;

  MenuViewModel() {
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    currentUser = _firebaseService.currentUser;
    userRole = await _firebaseService.getUserRole();
    notifyListeners();
  }

  void changePassword(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ChangePasswordPage()));
  }

  Future<void> navigateToProfile(BuildContext context) async {
    var user = _firebaseService.currentUser;
    if (user != null) {
      var docSnapshot = await _firebaseService.getUserProfile(user.uid);
      if (docSnapshot.exists) {
        String? userType = docSnapshot.data()?['userType'] as String?;
        switch (userType) {
          case 'Supervisor':
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SupervisorView(uid: user.uid)));
            break;
          case 'HR':
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => HRView(uid: user.uid)));
            break;
          case 'Instructor':
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => InstructorView(uid: user.uid)));
            break;
          case 'Student':
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StudentView(uid: user.uid)));
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Profile view not available for this user type'),
            ));
            break;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User profile data not found'),
        ));
      }
    }
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginView()),
                        (Route<dynamic> route) => false,
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Account Deletion'),
          content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteUserAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginView()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'Please re-login to confirm your identity and delete your account.');
      }
    }
  }
}
