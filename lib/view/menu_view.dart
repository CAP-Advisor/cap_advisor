import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/menu_viewmodel.dart';
import 'assign_instructor_view.dart';
import 'change_password_view.dart';
import 'student_task_view.dart';

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
                  if (model.userRole == 'Student') ...[
                    _buildMenuItem(context, "View Tasks",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentTasksView(
                                      studentId: model.currentUser?.uid ?? '',
                                      studentName:
                                          '',
                                    )))),
                    _buildMenuItem(context, "Assign Instructor",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AssigningInstructorView(
                                      studentId: model.currentUser?.uid ??
                                          '', // Pass the appropriate studentId
                                    )))),
                  ],
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
