import 'package:flutter/material.dart';
import '../service/firebase_service.dart';
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
      // Check if the student's name matches the provided name (case insensitive)
      final nameMatches = name == null ||
          student.name.toLowerCase().contains(name.toLowerCase());

      // Check if the student's address matches the provided address (case insensitive)
      final addressMatches = address == null ||
          student.address.toLowerCase() == address.toLowerCase();

      // Check if the student has at least one of the selected skills
      final skillsMatches = skills == null ||
          student.skills != null &&
              student.skills!.isNotEmpty &&
              skills.any(
                  (skill) => student.skills!.contains(skill.toLowerCase()));

      // Check if the student's GPA matches the provided GPA range (if gpa is not null)
      final gpaMatches = gpa == null ||
          (student.gpa != null &&
              student.gpa! >= gpa - 0.1 &&
              student.gpa! <= gpa + 0.1);

      // Return true only if all conditions are met
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
      // Fetch students from the Firebase service
      var students = await _firebaseService.fetchStudents();

      // Log the fetched students
      debugPrint('Fetched students: $students');

      // Cast the students to a list of `Student` objects
      _students = students.cast<Student>();

      // Log the cast students
      debugPrint('Cast students: $_students');

      // Notify listeners about the changes
      notifyListeners();
    } catch (e) {
      // Log any errors that occur
      debugPrint('Error fetching or casting students: $e');
    }
  }
}
