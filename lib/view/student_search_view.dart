import 'package:cap_advisor/resources/colors.dart';
import 'package:cap_advisor/view/student_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/student_search_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/filter_popup.dart';
import 'hr_view.dart';

class StudentSearchScreen extends StatelessWidget {
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: FilterPopup(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentViewModel>(
      builder: (context, studentViewModel, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "Student Search",
            onBack: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HRView(uid: 'uid'),
                ),
              );
            },
            onNotificationPressed: () {
              // Handle notification pressed
            },
            onMenuPressed: () {
              Navigator.of(context).pushNamed('/menu');
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 400,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.filter_alt),
                          onPressed: () {
                            _showFilterDialog(context);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: backgroundBoxColor,
                      ),
                      onChanged: (value) {
                        studentViewModel.filterStudents(name: value);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: studentViewModel.students.isEmpty
                      ? Center(
                          child: Text(
                            'No students found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: studentViewModel.students.length,
                          itemBuilder: (context, index) {
                            final student = studentViewModel.students[index];
                            return Container(
                              width: 350,
                              height: 133,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(
                                    10),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentView(
                                        uid: student.uid,
                                        isHR: true,
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: student.photoUrl != null
                                      ? NetworkImage(student.photoUrl!)
                                      : null,
                                  child: student.photoUrl == null
                                      ? Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(student.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    if (student.gpa != null)
                                      Text('GPA: ${student.gpa}'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    if (student.address != null &&
                                        student.address!.isNotEmpty)
                                      Text(student.address),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    if (student.skills != null &&
                                        student.skills!.isNotEmpty)
                                      Text(
                                          'Skills: ${student.skills?.join(', ')}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
