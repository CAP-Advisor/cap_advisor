import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../exceptions/custom_exception.dart';

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

  Future<void> searchInstructors(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot;
      if (query.isEmpty) {
        querySnapshot =
            await FirebaseFirestore.instance.collection('Instructor').get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('Instructor')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
      }

      instructors = querySnapshot.docs;
    } catch (e) {
      error = 'Failed to fetch instructors: $e';
      throw CustomException('Failed to fetch instructors: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAllInstructors() async {
    isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Instructor').get();

      instructors = querySnapshot.docs;
    } catch (e) {
      error = 'Failed to fetch instructors: $e';
      throw CustomException('Failed to fetch instructors: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignStudentToInstructor(
      String instructorId, String studentId, BuildContext context) async {
    DocumentReference instructorRef =
        FirebaseFirestore.instance.collection('Instructor').doc(instructorId);

    try {
      DocumentSnapshot snapshot = await instructorRef.get();

      if (!snapshot.exists) {
        throw Exception("Instructor does not exist!");
      }

      List<dynamic> studentList =
          (snapshot.data() as Map<String, dynamic>)['studentList'] ?? [];

      if (!studentList.contains(studentId)) {
        studentList.add(studentId);
        await instructorRef.update({'studentList': studentList});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('This student is already assigned to this instructor.'),
            backgroundColor: Colors.deepOrangeAccent,
          ),
        );
      }
    } catch (e) {
      error = 'Failed to assign student: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign student: $e'),
          backgroundColor: Colors.red,
        ),
      );
      throw CustomException('Failed to assign student: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
