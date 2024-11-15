import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/student_search_viewmodel.dart';

class FilterPopup extends StatefulWidget {
  @override
  _FilterPopupState createState() => _FilterPopupState();
}

class _FilterPopupState extends State<FilterPopup> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> skills = ["java", "Flutter", "Lab Work", "Data Analysis"];
  List<bool> selectedSkills = [false, false, false, false];
  String? selectedMajor;
  double? selectedGPA;
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentViewModel = Provider.of<StudentViewModel>(context);

    return AlertDialog(
      contentPadding: EdgeInsets.all(16.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Skills"),
                  Tab(text: "GPA"),
                  Tab(text: "Address"),
                ],
              ),
              Container(
                height: 200,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
                      itemCount: skills.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(skills[index]),
                          value: selectedSkills[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedSkills[index] = value ?? false;
                            });
                          },
                        );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'GPA',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            selectedGPA = value.isNotEmpty ? double.tryParse(value) : null;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedAddress = value.isNotEmpty ? value : null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  studentViewModel.filterStudents(
                    gpa: selectedGPA,
                    address: selectedAddress,
                    skills: skills.where((skill) => selectedSkills[skills.indexOf(skill)]).toList(),
                  );
                  Navigator.pop(context);
                },
                child: Text("Submit"),
              ),
              TextButton(
                onPressed: () {
                  studentViewModel.clearFilter();
                  Navigator.pop(context);
                },
                child: Text("Clear Filters"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
