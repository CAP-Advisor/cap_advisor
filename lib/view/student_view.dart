import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cap_advisor/view/student_skills_view.dart';
import 'package:cap_advisor/view/student_experience_view.dart';
import 'login_view.dart';

class StudentView extends StatelessWidget {
  final String uid;
  const StudentView({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildProfilePictureSection(context),
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(context) {
    return AppBar(
      backgroundColor: const Color(0xFF164863),
      title: const Text("CAP Advisor",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 20)),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // Define what happens when this is pressed
          },
        ),
        IconButton(
          icon: Icon(IconData(0xf11a, fontFamily: 'MaterialIcons')),
          onPressed: () {
            null;
          },
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginView()));
          },
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          height: 157,
          color: Colors.grey[200],
        ),
        Positioned(
          top: 75,
          left: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 75,
                backgroundColor: Colors.grey[300],
              ),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  // Implement actions based on selected value
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'view_profile_photo',
                    child: Text('View Profile Photo'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'choose_profile_photo',
                    child: Text('Choose Profile Photo'),
                  ),
                ],
                child: CircleAvatar(
                  child: const Icon(Icons.camera_alt, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 0,
          child: PopupMenuButton<String>(
            onSelected: (String value) {
              // Implement actions based on selected value for cover photo
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'view_cover_photo',
                child: Text('View Cover Photo'),
              ),
              const PopupMenuItem<String>(
                value: 'choose_cover_photo',
                child: Text('Choose Cover Photo'),
              ),
            ],
            icon: const Icon(Icons.camera_alt, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _editableTextRow("Student Name", Icons.edit, context),
          _editableTextRow("Email", Icons.edit, context),
          const SizedBox(height: 20),
          _buildTextFieldRow(
              Icons.edit, 'Enter your GitHub URL', 14, FontWeight.w500),
          SizedBox(height: 20),
          _buildTextFieldRow(
              Icons.edit, 'Enter a brief summary', 14, FontWeight.w500),
          const SizedBox(height: 60),
          _buildButtonWithIcon(context, 'Add Skills', Icons.add,
              Color(0xFF427D9D), SkillsView()),
          const SizedBox(height: 40),
          _buildButtonWithIcon(context, 'Add Experience', Icons.add,
              Color(0xFF427D9D), ExperienceView()),
        ],
      ),
    );
  }

  Widget _editableTextRow(String label, IconData icon, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        IconButton(
          icon: Icon(icon, color: Colors.black),
          onPressed: () {
            // Define what happens when this is pressed
          },
        ),
      ],
    );
  }

  Widget _buildTextFieldRow(
      IconData icon, String hintText, double fontSize, FontWeight fontWeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
            ),
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                fontFamily: 'Roboto'),
          ),
        ),
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            // Add action if necessary
          },
        ),
      ],
    );
  }

  Widget _buildButtonWithIcon(BuildContext context, String text, IconData icon,
      Color color, Widget targetPage) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: Icon(icon),
      label: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
