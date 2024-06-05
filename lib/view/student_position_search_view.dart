import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/student_position_search_model.dart';
import '../view-model/student_position_search_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_position_card.dart';
import '../widgets/custom_search_field.dart';

class StudentPositionSearchView extends StatefulWidget {
  @override
  _StudentPositionSearchViewState createState() =>
      _StudentPositionSearchViewState();
}

class _StudentPositionSearchViewState extends State<StudentPositionSearchView> {
  final TextEditingController searchController = TextEditingController();
  final StudentPositionSearchViewModel viewModel =
      StudentPositionSearchViewModel();

  List<StudentPositionSearchModel> positions = [];
  bool isLoading = true;
  late String studentId;

  @override
  void initState() {
    super.initState();
    fetchPositions();
    fetchCurrentUser();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    setState(() {
      viewModel.filterPositionsByTitle(searchController.text);
    });
  }

  Future<void> fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      studentId = user.uid;
    }
  }

  Future<void> fetchPositions() async {
    try {
      await viewModel.fetchPositions();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching positions: $e");
    }
  }

  Future<void> applyForPosition(StudentPositionSearchModel position) async {
    try {
      await viewModel.applyForPosition(position.id, studentId);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied for ${position.title}')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Position Search",
          onBack: () {
            Navigator.of(context).pop();
          },
          onNotificationPressed: () {
            // Handle notification pressed
          },
          onMenuPressed: () {
            Navigator.of(context).pushNamed('/menu');
          },
        ),
        body: Column(
          children: [
            CustomSearchField(
              controller: searchController,
              onChanged: (value) {
                // Handle search input changes
              }, hintText: 'Search Position',
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: viewModel.filteredPositions.length,
                      itemBuilder: (context, index) {
                        final position = viewModel.filteredPositions[index];
                        return CustomPositionCard(
                          title: position.title,
                          companyName: position.companyName,
                          description: position.description,
                          positionType: position.positionType,
                          skills: position.skills,
                          onPressed: () => applyForPosition(position),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
