import 'package:flutter/material.dart';
import '../exceptions/custom_exception.dart';
import '../model/student_model.dart';
import '../service/student_firebase_service.dart';

class StudentViewModel extends ChangeNotifier {
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  final StudentFirebaseService _firebaseService = StudentFirebaseService();

  List<Student> get students =>
      _filteredStudents.isNotEmpty ? _filteredStudents : _students;

  StudentViewModel() {
    fetchStudentsFromFirebase();
  }

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void filterStudents(
      {String? name,
      String? major,
      double? gpa,
      String? address,
      List<String>? skills}) {
    _filteredStudents = _students.where((student) {
      final nameMatches = name == null ||
          student.name.toLowerCase().contains(name.toLowerCase());

      final addressMatches = address == null ||
          student.address.toLowerCase() == address.toLowerCase();

      final skillsMatches = skills == null ||
          student.skills != null &&
              student.skills!.isNotEmpty &&
              skills.any(
                  (skill) => student.skills!.contains(skill.toLowerCase()));

      final gpaMatches = gpa == null ||
          (student.gpa != null &&
              student.gpa! >= gpa - 0.1 &&
              student.gpa! <= gpa + 0.1);

      return (gpa != null && gpaMatches) ||
          gpa == null && nameMatches && addressMatches && skillsMatches;
    }).toList();

    notifyListeners();
  }

  void clearFilter() {
    _filteredStudents = [];
    notifyListeners();
  }

  Future<void> fetchStudentsFromFirebase() async {
    try {
      var students = await _firebaseService.fetchStudents();

      debugPrint('Fetched students: $students');

      _students = students.cast<Student>();

      debugPrint('Cast students: $_students');

      notifyListeners();
    } catch (e) {
      throw CustomException('Error fetching or casting students: $e');
    }
  }
}
