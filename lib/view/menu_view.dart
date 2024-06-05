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
              elevation: 4, // Add elevation for depth
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildMenuItem(
                    context,
                    "View Profile",
                    Icons.person,
                    onTap: () => _viewModel.navigateToProfile(context),
                  ),
                  _buildMenuItem(
                    context,
                    "Change Password",
                    Icons.lock,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordPage()),
                    ),
                  ),
                  if (model.userRole == 'Student') ...[
                    Divider(), // Add a divider before student-specific options
                    _buildMenuItem(
                      context,
                      "View Tasks",
                      Icons.assignment,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentTasksView(
                            studentId: model.currentUser?.uid ?? '',
                            studentName:
                            '', // Pass the appropriate student name
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      "Assign Instructor",
                      Icons.person_add,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssigningInstructorView(
                            studentId: model.currentUser?.uid ??
                                '', // Pass the appropriate studentId
                          ),
                        ),
                      ),
                    ),
                    Divider(), // Add a divider after student-specific options
                  ],
                  _buildMenuItem(
                    context,
                    "Delete Account",
                    Icons.delete,
                    onTap: () => _viewModel.confirmDeleteAccount(context),
                  ),
                  _buildMenuItem(
                    context,
                    "Logout",
                    Icons.logout,
                    onTap: () => _viewModel.logout(context),
                  ),
                  Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 28),
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
