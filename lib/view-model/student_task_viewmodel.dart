import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/firebase_service.dart';

class StudentTasksViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  late TextEditingController searchController;
  late List<Map<String, dynamic>> _allTasks;
  late List<Map<String, dynamic>> _filteredTasks;
  bool isLoading = false;
  String? error;

  StudentTasksViewModel() {
    searchController = TextEditingController();
    _allTasks = [];
    _filteredTasks = [];
    fetchTasks();
  }

  List<Map<String, dynamic>> get tasks =>
      _filteredTasks.isNotEmpty ? _filteredTasks : _allTasks;

  Future<void> fetchTasks() async {
    try {
      FirebaseService firebaseService = FirebaseService();
      String userId = FirebaseService().currentUser!.uid;
      Map<String, dynamic>? studentDoc =
          await firebaseService.fetchStudentData(userId);
      if (studentDoc != null) {
        // Fetch all tasks initially
        QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
            .collection('Student')
            .doc(userId)
            .collection('Task')
            .get();
        _allTasks = taskSnapshot.docs
            .map((taskDoc) => taskDoc.data() as Map<String, dynamic>)
            .toList();
      } else {
        _allTasks = []; // Set _allTasks to an empty list if no tasks are found
      }
      // Notify listeners that tasks have been fetched
      notifyListeners();
    } catch (e) {
      print("Error fetching tasks: $e");
      // Set _allTasks to an empty list in case of an error
      _allTasks = [];
      // Notify listeners about the error
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
      _filteredTasks = []; // Reset filtered tasks if the query is empty
    } else {
      _filteredTasks = _allTasks.where((task) {
        String taskTitle = (task['Task Title'] ?? "").toLowerCase();
        return taskTitle.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners(); // Notify listeners that the filtered tasks have changed
    return _filteredTasks;
  }

  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
