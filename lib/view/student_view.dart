import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/student_model.dart';
import '../view-model/student_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import 'add_section_view.dart';
import '../service/firebase_service.dart';

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
  FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StudentViewModel>(
      create: (_) => StudentViewModel(uid),
      child: Consumer<StudentViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: isSupervisor
                ? CustomAppBar(
                    title: "CAP Advisor",
                    onBack: () {
                      Navigator.of(context).pop();
                    },
                    onNotificationPressed: () {},
                    onFeedback: () {
                      Navigator.of(context).pushNamed('/assign-feedback');
                    },
                    onMenuPressed: () {
                      Navigator.of(context).pushNamed('/menu');
                    },
                  )
                : isHR
                    ? CustomAppBar(
                        title: "CAP Advisor",
                        onBack: () {
                          Navigator.of(context).pop();
                        },
                        onNotificationPressed: () {},
                        onMenuPressed: () {
                          Navigator.of(context).pushNamed('/menu');
                        },
                        isHR: isHR,
                      )
                    : CustomAppBar(
                        title: "CAP Advisor",
                        onBack: () {
                          Navigator.of(context).pop();
                        },
                        onNotificationPressed: () {},
                        onJobPressed: isInstructor
                            ? null
                            : () {
                                Navigator.of(context)
                                    .pushNamed('/student-position-search');
                              },
                        onMenuPressed: () {
                          Navigator.of(context).pushNamed('/menu');
                        },
                        isInstructor: isInstructor,
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
                                    Color(0xFF427D9D),
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
              ))
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
            color: Color(0xFFDDF2FD),
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
            onPressed: () {
              // Define what happens when this is pressed
            },
          ),
      ],
    );
  }

  Widget _buildInformationCard(Student student) {
    List<Widget> infoRows = [];

    if (student.address.isNotEmpty) {
      infoRows.add(_informationRow("Address:", student.address));
    }
    if (student.github.isNotEmpty) {
      infoRows.add(_informationRow("GitHub:", student.github));
    }
    if (student.gpa > 0) {
      infoRows.add(_informationRow("GPA:", student.gpa.toString()));
    }

    if (infoRows.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      color: Color(0xFFDDF2FD),
      child: Container(
        width: 400,
        constraints: BoxConstraints(minHeight: 114.23),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Information:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            ...infoRows,
          ],
        ),
      ),
    );
  }

  Widget _informationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(Student student) {
    return Card(
      color: Color(0xFFDDF2FD),
      child: Container(
        width: 400,
        constraints: BoxConstraints(minHeight: 114.23),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Skills:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            for (var skill in student.skills)
              Text(
                skill,
                style: TextStyle(fontSize: 16),
                softWrap: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Student student) {
    return Card(
      color: Color(0xFFDDF2FD),
      child: Container(
        width: 400,
        constraints: BoxConstraints(minHeight: 114.23),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Experience:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            for (var exp in student.experience)
              Text(
                exp,
                style: TextStyle(fontSize: 16),
                softWrap: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, Widget targetPage) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
