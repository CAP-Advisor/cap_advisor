import 'package:firebase_auth/firebase_auth.dart';
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

  bool isLoading = true;
  late String studentId;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserAndPositions();
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

  Future<void> fetchCurrentUserAndPositions() async {
    try {
      await fetchCurrentUser();
      await viewModel.fetchPositions();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching data')));
    }
  }

  Future<void> fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      studentId = user.uid;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User not logged in')));
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
          onMenuPressed: () {
            Navigator.of(context).pushNamed('/menu');
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: CustomSearchField(
                controller: searchController,
                hintText: 'Search Position by Title',
                onChanged: (String value) {},
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : buildPositionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPositionList() {
    final positions = viewModel.filteredPositions;
    if (positions.isEmpty) {
      return Center(child: Text('No positions found'));
    }
    return ListView.builder(
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final position = positions[index];
        return CustomPositionCard(
          title: position.title,
          companyName: position.companyName,
          description: position.description,
          positionType: position.positionType,
          skills: position.skills,
          onPressed: () => applyForPosition(position),
        );
      },
    );
  }
}
