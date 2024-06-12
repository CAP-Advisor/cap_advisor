import 'package:cap_advisor/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/student_model.dart';
import '../service/student_firebase_service.dart';
import '../view-model/student_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import 'add_section_view.dart';

class StudentView extends StatelessWidget {
  final String uid;
  final bool isSupervisor;
  final bool isInstructor;
  final bool isHR;

  StudentView({
    Key? key,
    required this.uid,
    this.isSupervisor = false,
    this.isInstructor = false,
    this.isHR = false,
  }) : super(key: key);

  final TextEditingController _nameController = TextEditingController();
  StudentFirebaseService firebaseService = StudentFirebaseService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StudentViewModel>(
      create: (_) => StudentViewModel(uid),
      child: Consumer<StudentViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "CAP Advisor",
              onBack: (isSupervisor || isInstructor || isHR)
                  ? () {
                      Navigator.of(context).pop();
                    }
                  : null,
              onFeedback: isSupervisor
                  ? () {
                      Navigator.of(context).pushNamed('/assign-feedback');
                    }
                  : null,
              onMenuPressed: () {
                Navigator.of(context).pushNamed('/menu');
              },
              isHR: isHR,
              isInstructor: isInstructor,
              onJobPressed: !isSupervisor && !isInstructor && !isHR
                  ? () {
                      Navigator.of(context)
                          .pushNamed('/student-position-search');
                    }
                  : null,
            ),
            body: model.isLoading
                ? Center(child: CircularProgressIndicator())
                : model.currentStudent == null
                    ? Center(
                        child: Text(model.error ?? 'No student data available'))
                    : SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            _buildProfileHeader(context, model),
                            SizedBox(height: 60),
                            if (!isSupervisor && !isInstructor && !isHR)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: _buildButton(
                                    context,
                                    'Add Section',
                                    primaryColor,
                                    SectionView(
                                      firebaseService: firebaseService,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 10),
                            _buildInfoSection(context, model),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, StudentViewModel _viewModel) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: (_viewModel.currentStudent?.coverPhotoUrl != null)
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        NetworkImage(_viewModel.currentStudent!.coverPhotoUrl!))
                : null,
            color: Colors.grey[300],
          ),
        ),
        Positioned(
          top: 130,
          left: 20,
          child: CircleAvatar(
            radius: 75,
            backgroundColor: Colors.grey[300],
            backgroundImage: _viewModel.currentStudent?.photoUrl != null
                ? NetworkImage(_viewModel.currentStudent!.photoUrl!)
                : null,
            child: _viewModel.currentStudent?.photoUrl == null
                ? Text(_viewModel.currentStudent?.name.substring(0, 1) ?? 'A',
                    style: TextStyle(fontSize: 40))
                : null,
          ),
        ),
        if (!isSupervisor && !isInstructor && !isHR)
          Positioned(
              right: 16,
              bottom: 16,
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  _viewModel.handleProfileAction(context, value);
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
                  const PopupMenuItem<String>(
                    value: 'view_cover_photo',
                    child: Text('View Cover Photo'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'choose_cover_photo',
                    child: Text('Choose Cover Photo'),
                  ),
                ],
                child: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.add_a_photo, color: Colors.white),
                ),
              )),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, StudentViewModel viewModel) {
    Student? student = viewModel.currentStudent;
    if (student == null) return SizedBox.shrink();

    List<Widget> infoSection = [];

    if (student.name.isNotEmpty) {
      infoSection.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(student.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          if (!isSupervisor && !isInstructor && !isHR)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () => _showNameDialog(context, viewModel),
            ),
        ],
      ));
    }

    if (student.email.isNotEmpty) {
      infoSection.add(SizedBox(height: 10));
      infoSection.add(_editableTextRow("Email", null, student.email, context));
    }

    if (student.summary.isNotEmpty) {
      infoSection.add(SizedBox(height: 30));
      infoSection.add(_editableTextRow(
          "Summary", null, student.summary, context,
          multiline: true));
    }
    if (student.address.isNotEmpty ||
        student.github.isNotEmpty ||
        student.gpa > 0) {
      infoSection.add(SizedBox(height: 20));
      infoSection.add(Center(child: _buildInformationCard(student)));
    }

    if (student.skills.isNotEmpty) {
      infoSection.add(SizedBox(height: 20));
      infoSection.add(Center(child: _buildSkillsCard(student)));
    }

    if (student.experience.isNotEmpty) {
      infoSection.add(SizedBox(height: 20));
      infoSection.add(Center(child: _buildExperienceCard(student)));
    }

    if (viewModel.trainings.isNotEmpty) {
      infoSection.add(SizedBox(height: 20));
      infoSection.add(_buildTrainingSection(context, viewModel));
    }

    infoSection.add(SizedBox(height: 50));

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: infoSection,
      ),
    );
  }

  Widget _buildTrainingSection(
      BuildContext context, StudentViewModel viewModel) {
    if (viewModel.trainings.isEmpty) {
      print('No training records found.');
      return SizedBox.shrink();
    }

    List<Widget> trainingCards = viewModel.trainings.map((training) {
      return Column(
        children: [
          Card(
            color: cardColor,
            child: Container(
              width: 400,
              constraints: BoxConstraints(minHeight: 114.23),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Feedback ${training.course}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  Text("${training.feedback}", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: trainingCards,
    );
  }

  Widget _editableTextRow(
      String label, IconData? icon, String value, BuildContext context,
      {bool multiline = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            softWrap: multiline,
            maxLines: multiline ? null : 1,
            overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        if (icon != null)
          IconButton(
            icon: Icon(icon, color: Colors.black),
            onPressed: () {},
          ),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, String label, Color color, Widget targetView) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetView),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label, style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  Widget _buildInformationCard(Student student) {
    return Card(
      color: cardColor,
      child: Container(
        width: 400,
        constraints: BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (student.address.isNotEmpty)
              Text("Address: ${student.address}",
                  style: TextStyle(fontSize: 16)),
            if (student.github.isNotEmpty) SizedBox(height: 10),
            if (student.github.isNotEmpty)
              Text("Github: ${student.github}", style: TextStyle(fontSize: 16)),
            if (student.gpa > 0) SizedBox(height: 10),
            if (student.gpa > 0)
              Text("GPA: ${student.gpa.toString()}",
                  style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(Student student) {
    List<String> skills = student.skills;
    if (skills.isEmpty) return SizedBox.shrink();

    return Card(
      color: cardColor,
      child: Container(
        width: 400,
        constraints: BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Skills",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            for (var skill in skills)
              Text(
                skill,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Student student) {
    List<String> experience = student.experience;
    if (experience.isEmpty) return SizedBox.shrink();

    return Card(
      color: cardColor,
      child: Container(
        width: 400,
        constraints: BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Experience",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            for (var exp in experience)
              Text(
                exp,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, StudentViewModel _viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Name'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              bool success =
                  await _viewModel.updateStudentName(_nameController.text);
              if (success) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update name'),
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
