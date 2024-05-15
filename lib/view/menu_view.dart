import 'package:flutter/material.dart';
import '../view-model/menu_viewmodel.dart';
import 'change_password_view.dart';

class MenuView extends StatelessWidget {
  final MenuViewModel _viewModel = MenuViewModel();

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              ),
            ),
            _buildMenuItem(context, "View Profile",
                onTap: () => _viewModel.navigateToProfile(context)),
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
