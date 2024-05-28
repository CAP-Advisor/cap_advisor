import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../view-model/assign_instructor_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_search_field.dart';
import 'instructor_view.dart';

class InstructorSearchView extends StatelessWidget {
  final String studentId;
  const InstructorSearchView({Key? key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InstructorSearchViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Assign Instructor',
          onNotificationPressed: () {
            // Define what happens when notification button is pressed
          },
          onMenuPressed: () {
            Navigator.of(context).pushNamed('/menu');
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.0,
            ),
            Consumer<InstructorSearchViewModel>(
              builder: (context, model, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomSearchField(
                      controller: model.searchController,
                      onChanged: (value) {
                        model.searchInstructors(value);
                      },
                      hintText: 'Search Instructor by Name',
                    ),
                  ),
                );
              },
            ),
            Consumer<InstructorSearchViewModel>(
              builder: (context, model, child) {
                if (model.isLoading) {
                  return CircularProgressIndicator();
                }

                return Expanded(
                  child: model.instructors.isEmpty
                      ? Center(child: Text('No instructors found'))
                      : ListView.builder(
                          itemCount: model.instructors.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot instructor =
                                model.instructors[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                elevation: 4,
                                color: Color(0xFFDDF2FD),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InstructorView(
                                          uid: instructor.id,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        instructor['photoUrl'] ?? ''),
                                  ),
                                  title: Text(instructor['name']),
                                  subtitle: Text(instructor['email']),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      model.assignStudentToInstructor(
                                          instructor.id, studentId, context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Student assigned successfully')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFF427D9D),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text('Assign'),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
