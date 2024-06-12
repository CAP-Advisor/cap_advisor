import 'package:cap_advisor/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../view-model/assign_instructor_viewmodel.dart';
import '../view-model/instructor_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_search_field.dart';
import 'instructor_view.dart';

class AssigningInstructorView extends StatelessWidget {
  final String studentId;
  const AssigningInstructorView({Key? key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssigningInstructorViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Assign Instructor',
          onBack: () {
            Navigator.of(context).pop();
          },
          onJobPressed: () {
            Navigator.of(context).pushNamed('/student-position-search');
          },
          onMenuPressed: () {
            Navigator.of(context).pushNamed('/menu');
          },
          onNotificationPressed: () {},
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0),
            Consumer<AssigningInstructorViewModel>(
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
            Consumer<AssigningInstructorViewModel>(
              builder: (context, model, child) {
                if (model.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (model.error != null) {
                  return Center(child: Text('Error: ${model.error}'));
                }

                return Expanded(
                  child: model.instructors.isEmpty
                      ? Center(child: Text('No instructors found'))
                      : ListView.builder(
                          itemCount: model.instructors.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot instructorSnapshot =
                                model.instructors[index];
                            Map<String, dynamic>? instructorData =
                                instructorSnapshot.data()
                                    as Map<String, dynamic>?;

                            if (instructorData == null) {
                              return SizedBox();
                            }

                            String photoUrl =
                                instructorData.containsKey('photoUrl')
                                    ? instructorData['photoUrl'] ?? ''
                                    : '';
                            String name = instructorData['name'] ?? 'No Name';
                            String email =
                                instructorData['email'] ?? 'No Email';
                            String firstLetter = name.isNotEmpty ? name[0] : '';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 6.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                elevation: 4,
                                color: cardColor,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeNotifierProvider(
                                          create: (_) => InstructorViewModel(
                                              instructorSnapshot.id),
                                          child: InstructorView(
                                            uid: instructorSnapshot.id,
                                            isStudent: true, // Pass the flag
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : null,
                                    child: photoUrl.isEmpty
                                        ? Text(
                                            firstLetter,
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          )
                                        : null,
                                  ),
                                  title: Text(name),
                                  subtitle: Text(email),
                                  trailing: IconButton(
                                    icon: Icon(Icons.assignment),
                                    onPressed: () {
                                      model.assignStudentToInstructor(
                                          instructorSnapshot.id,
                                          studentId,
                                          context);
                                    },
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
