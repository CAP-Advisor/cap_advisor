import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback onMenuPressed;
  final VoidCallback? onFeedback;
  final VoidCallback? onJobPressed;
  final bool isInstructor;
  final bool isSupervisor;
  final bool isHR;
  final bool isStudentView;

  static const IconData customJobIcon = IconData(0xf11a, fontFamily: 'MaterialIcons');

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
    this.onFeedback,
    this.onJobPressed,
    required this.onMenuPressed,
    this.isInstructor = false,
    this.isSupervisor = false,
    this.isHR = false,
    this.isStudentView = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    if (onFeedback != null) {
      actions.add(
        IconButton(
          icon: Icon(Icons.add_comment),
          onPressed: onFeedback!,
          color: Colors.white,
          tooltip: 'Feedback',
        ),
      );
    }

    if (onJobPressed != null) {
      actions.add(
        IconButton(
          icon: Icon(customJobIcon),
          onPressed: onJobPressed!,
          color: Colors.white,
        ),
      );
    }

    actions.addAll([
      IconButton(
        icon: Icon(Icons.menu),
        onPressed: onMenuPressed,
        color: Colors.white,
      ),
    ]);

    return AppBar(
      backgroundColor: Color(0xFF164863),
      leading: onBack != null
          ? IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBack,
        color: Colors.white,
      )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: actions,
    );
  }
}