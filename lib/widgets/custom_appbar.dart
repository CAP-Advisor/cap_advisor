import 'package:flutter/material.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onNotificationPressed;
  final VoidCallback onMenuPressed;
  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onBack,
    required this.onNotificationPressed,
    required this.onMenuPressed,
  }) : super(key: key);
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF164863),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBack,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: onNotificationPressed,
          color: Colors.white,
        ),
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: onMenuPressed,
          color: Colors.white,
        ),
      ],
    );
  }
}