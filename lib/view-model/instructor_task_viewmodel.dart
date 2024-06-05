import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/student_firebase_service.dart';

class InstructorTasksViewModel extends ChangeNotifier {
  final StudentFirebaseService _firebaseService = StudentFirebaseService();
  late TextEditingController searchController;
  late List<Map<String, dynamic>> _allTasks;
  late List<Map<String, dynamic>> _filteredTasks;
  late String _studentId;
  bool isLoading = false;
  String? error;

  InstructorTasksViewModel(String studentId) {
    _studentId = studentId;
    searchController = TextEditingController();
    _allTasks = [];
    _filteredTasks = [];
    fetchTasks();
  }

  List<Map<String, dynamic>> get tasks =>
      _filteredTasks.isNotEmpty ? _filteredTasks : _allTasks;

  Future<void> fetchTasks() async {
    try {
      StudentFirebaseService firebaseService = StudentFirebaseService();
      Map<String, dynamic>? studentDoc =
          await firebaseService.fetchStudentData(_studentId);
      if (studentDoc != null) {
        QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
            .collection('Student')
            .doc(_studentId)
            .collection('Task')
            .get();
        _allTasks = taskSnapshot.docs
            .map((taskDoc) => taskDoc.data() as Map<String, dynamic>)
            .toList();
      } else {
        _allTasks = [];
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching tasks: $e");
      _allTasks = [];
      notifyListeners();
    }
  }

  Future<void> fetchTasksForSpecificStudent(String studentId) async {
    isLoading = true;
    notifyListeners();

    try {
      _allTasks =
          await _firebaseService.fetchTasksForSpecificStudent(studentId);
    } catch (e) {
      error = "Error fetching tasks: $e";
      _allTasks = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> filterTasks(String query) {
    if (query.isEmpty) {
      _filteredTasks = [];
    } else {
      _filteredTasks = _allTasks.where((task) {
        String taskTitle = (task['Task Title'] ?? "").toLowerCase();
        return taskTitle.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
    return _filteredTasks;
  }

  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
