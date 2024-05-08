import 'package:flutter/material.dart';
import '../model/student_model.dart';
import '../view-model/supervisor_viewmodel.dart';
import '../view/add_task_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupervisorView extends StatelessWidget {
  final SupervisorViewModel _viewModel = SupervisorViewModel();

  Widget logoutBtn(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginView()));
        },
        child: const Text(
          'Logout', // Changed the text to indicate the action clearly
          style: TextStyle(color: Color(0xFF427D9D)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF164863),
        title: Text(
          "CAP Advisor",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _viewModel.fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Student> students = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        height: 157,
                        color: Colors.grey[200],
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      Positioned(
                        top: 75,
                        left: 20,
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey[300],
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () {},
                              ),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 70.0, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Supervisor Name",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                // Add action for editing name
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Email",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.black),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F8F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              prefixIcon:
                                  Icon(Icons.search, color: Color(0xFF164863)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F8F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView.builder(
                            physics:
                                NeverScrollableScrollPhysics(), // Ensures the ListView doesn't scroll separately
                            shrinkWrap:
                                true, // Makes the ListView only as tall as its contents
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              Student student = students[index];
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
                                            builder: (context) =>
                                                AddTaskView()),
                                      );
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
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No students found'));
          }
        },
      ),
    );
  }
}