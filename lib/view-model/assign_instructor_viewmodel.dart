import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssigningInstructorViewModel extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> instructors = [];
  bool isLoading = false;
  String? error;

  AssigningInstructorViewModel() {
    searchController.addListener(_onSearchChanged);
    _fetchAllInstructors();
  }

  void _onSearchChanged() {
    searchInstructors(searchController.text);
  }

  void searchInstructors(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot;
      if (query.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('Instructor')
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('Instructor')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
      }

      instructors = querySnapshot.docs;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _fetchAllInstructors() async {
    isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Instructor')
          .get();

      instructors = querySnapshot.docs;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void assignStudentToInstructor(String instructorId, String studentId, BuildContext context) async {
    DocumentReference instructorRef =
    FirebaseFirestore.instance.collection('Instructor').doc(instructorId);

    bool studentAssigned = false;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(instructorRef);

      if (!snapshot.exists) {
        throw Exception("Instructor does not exist!");
      }

      List<dynamic> studentList = [];
      if (snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        studentList = data['studentList'] ?? [];
      }

      if (!studentList.contains(studentId)) {
        studentList.add(studentId);
        transaction.update(instructorRef, {'studentList': studentList});
        studentAssigned = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This student is already assigned to this instructor.'),
          ),
        );
      }
    });

    if (studentAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student assigned successfully')),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
