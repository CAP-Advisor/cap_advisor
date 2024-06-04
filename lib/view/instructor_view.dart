import 'package:cap_advisor/view/student_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/instructor_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_search_field.dart';
import 'instructor_task_view.dart';

class InstructorView extends StatelessWidget {
  final String uid;
  InstructorView({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InstructorViewModel>(
      create: (_) => InstructorViewModel(uid),
      child: Consumer<InstructorViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "CAP Advisor",
              onNotificationPressed: () {},
              onMenuPressed: () {
                Navigator.of(context).pushNamed('/menu');
              },
            ),
            body: model.isLoading
                ? Center(child: CircularProgressIndicator())
                : model.currentInstructor == null
                    ? Center(
                        child:
                            Text(model.error ?? 'No instructor data available'))
                    : Column(
                        children: [
                          _buildProfileHeader(context, model),
                          _buildInstructorDetails(context, model),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CustomSearchField(
                              controller: model.searchController,
                              onChanged: (value) {
                                model.filterStudents(value);
                              },
                              hintText: 'Search for student',
                            ),
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: model.filteredStudents.isEmpty
                                ? Center(child: Text('No students found'))
                                : ListView.builder(
                                    itemCount: model.filteredStudents.length,
                                    itemBuilder: (context, index) {
                                      final student =
                                          model.filteredStudents[index];
                                      return Container(
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFCFE0E9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            backgroundImage:
                                                student.photoUrl != null
                                                    ? NetworkImage(
                                                        student.photoUrl!)
                                                    : null,
                                            child: student.photoUrl == null
                                                ? Text(student.name[0])
                                                : null,
                                          ),
                                          title: Text(student.name),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(student.training),
                                              Text(student.company),
                                              Text(student.email),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      InstructorTasksView(
                                                    studentId: student.uid,
                                                    studentName: student.name,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.task,
                                              color: Color(0xFF164863),
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    StudentView(
                                                  uid: student.uid,
                                                  isInstructor: true,
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

  Widget _buildInstructorDetails(
      BuildContext context, InstructorViewModel _viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_viewModel.instructorName ?? 'Name not available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_viewModel.instructorEmail ?? 'Email not available',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, InstructorViewModel _viewModel) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: (_viewModel.currentInstructor?.coverPhotoUrl != null)
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        _viewModel.currentInstructor!.coverPhotoUrl!))
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
            backgroundImage: _viewModel.currentInstructor?.photoUrl != null
                ? NetworkImage(_viewModel.currentInstructor!.photoUrl!)
                : null,
            child: _viewModel.currentInstructor?.photoUrl == null
                ? Text(
                    _viewModel.currentInstructor?.name.substring(0, 1) ?? 'A',
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
        )
      ],
    );
  }
}
