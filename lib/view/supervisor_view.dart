import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/supervisor_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_search_field.dart';
import 'add_task_view.dart';
import 'student_view.dart';

class SupervisorView extends StatelessWidget {
  final String uid;

  const SupervisorView({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupervisorViewModel(),
      child: Consumer<SupervisorViewModel>(
        builder: (context, _viewModel, child) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "CAP Advisor",
              onNotificationPressed: () {},
              onFeedback: () {
                Navigator.of(context).pushNamed('/assign-feedback');
              },
              onMenuPressed: () {
                Navigator.of(context).pushNamed('/menu');
              },
            ),
            body: _viewModel.currentSupervisor == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildProfileHeader(context, _viewModel),
                      _buildSupervisorDetails(context, _viewModel),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomSearchField(
                          controller: _viewModel.searchController,
                          onChanged: (value) {
                            _viewModel.filterStudents(value);
                          },
                          hintText: 'search for student',
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: _viewModel.filteredStudents.isEmpty
                            ? Center(child: Text('No students found'))
                            : ListView.builder(
                                itemCount: _viewModel.filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student =
                                      _viewModel.filteredStudents[index];
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddTaskView(
                                                  studentId: student.uid,
                                                  studentName: student.name),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF164863),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                            builder: (context) => StudentView(
                                              uid: student.uid,
                                              isSupervisor: true,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, SupervisorViewModel _viewModel) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisorDetails(
      BuildContext context, SupervisorViewModel _viewModel) {
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
                onPressed: () => _showNameDialog(context, _viewModel),
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

  void _showNameDialog(BuildContext context, SupervisorViewModel _viewModel) {
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
