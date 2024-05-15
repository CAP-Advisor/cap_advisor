import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/student_model.dart';
import '../model/supervisor_model.dart';

class JobAndTrainingApplicantsViewModel extends ChangeNotifier {
  List<Student> applicants = [];
  List<SupervisorModel> supervisors = [];
  List<Student> filteredApplicants = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String hrDocumentId;

  JobAndTrainingApplicantsViewModel({required this.hrDocumentId}) {
    fetchApplicants();
    fetchSupervisors();
  }
  String filterType =
      ''; // Store selected filter type (e.g., 'gpa', 'address', 'skill')
  String filterValue = ''; // Store selected filter value

  // Method to apply filtering logic based on filter options
  void applyFilter() {
    if (filterType.isNotEmpty && filterValue.isNotEmpty) {
      switch (filterType) {
        case 'gpa':
          // Apply filter by GPA logic
          break;
        case 'address':
          // Apply filter by Address logic
          break;
        case 'skill':
          // Apply filter by Skill logic
          break;
        default:
          // Handle default case
          break;
      }
      // Notify listeners to update the view
      notifyListeners();
    }
  }

  // Method to update filter options
  void updateFilter(String type, String value) {
    filterType = type;
    filterValue = value;
    // Apply filter immediately when filter options are updated
    applyFilter();
  }

  Future<void> fetchApplicants() async {
    var snapshot = await _db.collection('Student').get();
    applicants =
        snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    filteredApplicants = List.from(applicants);
    notifyListeners();
  }

  Future<void> fetchSupervisors() async {
    var hrDoc = await _db.collection('HR').doc(hrDocumentId).get();
    if (hrDoc.exists) {
      var hrId = hrDoc.id;

      var snapshot = await _db
          .collection('Supervisor')
          .where('hrId', isEqualTo: hrId)
          .get();
      supervisors =
          snapshot.docs.map((doc) => SupervisorModel.fromFirestore(doc)).toList();
      notifyListeners();
    }
  }

  void filterApplicants(String query) {
    if (query.isEmpty) {
      filteredApplicants = List.from(applicants);
    } else {
      filteredApplicants = applicants.where((applicant) {
        return applicant.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> approveApplicant(BuildContext context, int index) async {
    // Logic to approve applicant
    print("Approved: ${filteredApplicants[index].name}");
    await _showSupervisorSelectionDialog(context, index);
    notifyListeners();
  }

  Future<void> rejectApplicant(int index) async {
    final student = filteredApplicants[index];
    applicants.removeWhere((applicant) => applicant.uid == student.uid);
    filteredApplicants.removeAt(index);

    await _updateApplicantInCollection('Training', student.uid);
    await _updateApplicantInCollection('Job Position', student.uid);

    notifyListeners();
  }

  Future<void> _showSupervisorSelectionDialog(
      BuildContext context, int applicantIndex) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Supervisor'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supervisors.length,
              itemBuilder: (context, index) {
                final supervisor = supervisors[index];
                return ListTile(
                  title: Text(supervisor.name),
                  onTap: () {
                    _assignStudentToSupervisor(applicantIndex, supervisor);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _assignStudentToSupervisor(
      int applicantIndex, SupervisorModel supervisor) async {
    final student = filteredApplicants[applicantIndex];
    final supervisorRef = _db.collection('Supervisor').doc(supervisor.uid);

    await supervisorRef.update({
      'studentList': FieldValue.arrayUnion([student.uid])
    });

    notifyListeners();
  }

  Future<void> _updateApplicantInCollection(
      String collectionName, String studentId) async {
    var snapshot = await _db.collection(collectionName).get();

    for (var doc in snapshot.docs) {
      if (doc.data()['applicantList'] != null &&
          (doc.data()['applicantList'] as List).contains(studentId)) {
        await _db.collection(collectionName).doc(doc.id).update({
          'applicantList': FieldValue.arrayRemove([studentId])
        });
      }
    }
  }
}
