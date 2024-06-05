import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/firebase_service.dart';
import '../service/student_firebase_service.dart';

class StudentTasksViewModel extends ChangeNotifier {
  late TextEditingController searchController;
  late List<Map<String, dynamic>> _allTasks;
  late List<Map<String, dynamic>> _filteredTasks;
  bool isLoading = false;

  StudentTasksViewModel() {
    searchController = TextEditingController();
    _allTasks = [];
    _filteredTasks = [];
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearData();
      } else {
        fetchTasks();
      }
    });
  }

  List<Map<String, dynamic>> get tasks =>
      _filteredTasks.isNotEmpty ? _filteredTasks : _allTasks;

  Future<void> fetchTasks() async {
    try {
      isLoading = true;
      notifyListeners();

      StudentFirebaseService firebaseService = StudentFirebaseService();
      String userId = FirebaseService().currentUser!.uid;
      Map<String, dynamic>? studentDoc =
      await firebaseService.fetchStudentData(userId);
      if (studentDoc != null) {
        QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
            .collection('Student')
            .doc(userId)
            .collection('Task')
            .get();
        _allTasks = taskSnapshot.docs
            .map((taskDoc) => taskDoc.data() as Map<String, dynamic>)
            .toList();
      } else {
        _allTasks = [];
      }
      _filteredTasks = [];
    } catch (e) {
      print("Error fetching tasks: $e");
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

  void _clearData() {
    _allTasks.clear();
    _filteredTasks.clear();
    searchController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
