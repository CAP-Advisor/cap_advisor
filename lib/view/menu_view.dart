import 'package:cap_advisor/view/student_task_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/menu_viewmodel.dart';
import 'change_password_view.dart';
import 'final_feedback_view.dart'; // Import TaskView

class MenuView extends StatelessWidget {
  final MenuViewModel _viewModel = MenuViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuViewModel>(
      create: (_) => _viewModel,
      child: Consumer<MenuViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Menu"),
            ),
            body: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: <Widget>[
                  _buildMenuItem(
                    context,
                    "Change Password",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordPage()),
                    ),
                  ),
                  _buildMenuItem(context, "View Profile",
                      onTap: () => _viewModel.navigateToProfile(context)),
                  if (model.userRole ==
                      'Student') // Show only if user is a student
                    _buildMenuItem(context, "View Tasks",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentTasksView())
                        )),
                  _buildMenuItem(context, "Delete Account",
                      onTap: () => _viewModel.confirmDeleteAccount(context)),
                  _buildMenuItem(context, "Logout",
                      onTap: () => _viewModel.logout(context)),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.all(20),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title,
      {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
