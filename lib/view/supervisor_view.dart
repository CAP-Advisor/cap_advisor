import 'package:cap_advisor/view/student_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/student_model.dart';
import '../view-model/supervisor_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_search_field.dart';
import 'add_task_view.dart';
import 'login_view.dart';
import '../view/menu_view.dart';

class SupervisorView extends StatelessWidget {
  final String uid;
  SupervisorView({required this.uid});

  final SupervisorViewModel _viewModel = SupervisorViewModel();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "CAP Advisor",
        onNotificationPressed: () {},
        onFeedback: () {},
        onMenuPressed: () {
          //Navigator.of(context).pushNamed('/menu');
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginView()));
        },
      ),
      body: FutureBuilder<bool>(
        future: _viewModel.setCurrentSupervisor(),
        builder: (context, supervisorSnapshot) {
          if (supervisorSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (supervisorSnapshot.hasError ||
              !supervisorSnapshot.hasData ||
              !supervisorSnapshot.data!) {
            return Center(
                child: Text("Failed to load supervisor details or no data."));
          }

          return Column(
            children: [
              _buildProfileHeader(context),
              _buildSupervisorDetails(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomSearchField(
                  controller: _viewModel.searchController,
                  onChanged: (value) {
                    _viewModel.filterStudents(value);
                  },
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Student>>(
                  future: _viewModel.loadStudentsForSupervisor(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return Text('No students found');
                    }
                    return _buildStudentList(snapshot.data!);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: (_viewModel.currentSupervisor?.coverPhotoUrl != null)
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        _viewModel.currentSupervisor!.coverPhotoUrl!))
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
            backgroundImage: _viewModel.currentSupervisor?.photoUrl != null
                ? NetworkImage(_viewModel.currentSupervisor!.photoUrl!)
                : null,
            child: _viewModel.currentSupervisor?.photoUrl == null
                ? Text(
                    _viewModel.currentSupervisor?.name.substring(0, 1) ?? 'A',
                    style: TextStyle(fontSize: 40))
                : null,
          ),
        ),
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

  Widget _buildSupervisorDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70.0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_viewModel.supervisorName ?? 'Name not available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.black),
                onPressed: () => _showNameDialog(context),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_viewModel.supervisorEmail ?? 'Email not available',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<Student> students) {
    List<Student> filteredList =
        _viewModel.filterStudentsList(students, _searchController.text);
    if (filteredList.isEmpty) {
      return Center(
        child: Text('No students found'),
      );
    }
    return ListView.builder(
      //itemCount: _viewModel.filteredStudents.length,
      itemCount: filteredList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //final student = _viewModel.filteredStudents[index];
        final student = filteredList[index];
        return Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFCFE0E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Text(student.name[0]),
            ),
            title: Text(student.name),
            subtitle: Text(student.email),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => AddTaskView(studentId:student.uid,studentName:student.name)),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF164863),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Add Task',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentView(uid: student.uid),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showNameDialog(BuildContext context) {
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
                  await _viewModel.updateSupervisorName(_nameController.text);
              if (success) {
                Navigator.pop(context);
              } else {
                // Show error message
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
