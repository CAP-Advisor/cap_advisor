import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/student_search_viewmodel.dart';
import '../widgets/filter_popup.dart';
import 'hr_view.dart';

class StudentSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentViewModel>(
      builder: (context, studentViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Student Search',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
            backgroundColor: Color(0xFF164863),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications, color: Color(0xFFFFFFFF)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.menu, color: Color(0xFFFFFFFF)),
                onPressed: () {
                  Navigator.of(context).pushNamed('/menu');
                },
              ),
            ],
            iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          studentViewModel.filterStudents(name: value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: FilterPopup(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: studentViewModel.students.length,
                    itemBuilder: (context, index) {
                      final student = studentViewModel.students[index];
                      return Container(
                        width: 387,
                        height: 133,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Color(0xFFDDF2FD),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(Icons.person),
                          ),
                          title: Text(student.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student.major),
                              Text('GPA: ${student.gpa}'),
                              Text(student.address),
                              Text('Skills: ${student.skills?.join(', ')}'),
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
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Color(0xFF164863),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            currentIndex: 2,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HRView(uid: '')),
                  );
                  break;
                case 1:
                // Navigate to Feedback View
                  break;
                case 2:
                // Already on Student Search View, no action needed
                  break;
              }
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Positions'),
              BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
              BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Student Search'),
            ],
          ),
        );
      },
    );
  }
}
