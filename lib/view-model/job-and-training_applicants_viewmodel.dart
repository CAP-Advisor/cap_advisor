import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/student_model.dart';
import '../model/supervisor_model.dart';
import '../service/firebase_service.dart';

class JobAndTrainingApplicantsViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Student> applicants = [];
  List<SupervisorModel> supervisors = [];
  List<Student> filteredApplicants = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String hrDocumentId;

  JobAndTrainingApplicantsViewModel(
      {required this.hrDocumentId,
      required String positionId,
      required String positionType}) {
    fetchApplicants(hrDocumentId, positionType);
    fetchSupervisors();
  }

  String filterType = '';
  String filterValue = '';

  void applyFilter() {
    if (filterType.isNotEmpty && filterValue.isNotEmpty) {
      switch (filterType) {
        case 'gpa':
          break;
        case 'address':
          break;
        case 'skill':
          break;
        default:
          break;
      }
      notifyListeners();
    }
  }

  void updateFilter(String type, String value) {
    filterType = type;
    filterValue = value;
    applyFilter();
  }

  Future<void> fetchApplicants(String positionId, String positionType) async {
    applicants =
        await _firebaseService.fetchApplicants(positionId, positionType);
    filteredApplicants = List.from(applicants);
    notifyListeners();
  }

  Future<void> fetchSupervisors() async {
    supervisors = await _firebaseService.fetchSupervisors(hrDocumentId);
    notifyListeners();
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

  Future<SupervisorModel?> _showSupervisorSelectionDialog(
      BuildContext context) async {
    return showDialog<SupervisorModel>(
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
                    Navigator.of(context).pop(supervisor);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> approveApplicant(BuildContext context, int index) async {
    final student = filteredApplicants[index];
    final selectedSupervisor = await _showSupervisorSelectionDialog(context);
    if (selectedSupervisor != null) {
      try {
        await _firebaseService.assignStudentToSupervisor(
            student.uid, selectedSupervisor);
        await _updateApplicantInCollection('Job Position', student.uid);
        await _updateApplicantInCollection('Training Position', student.uid);
        filteredApplicants.removeAt(index);
        notifyListeners();
      } catch (e) {
        print("Failed to approve applicant: $e");
      }
    }
  }

  Future<void> rejectApplicant(int index) async {
    final student = filteredApplicants[index];
    applicants.removeWhere((applicant) => applicant.uid == student.uid);
    filteredApplicants.removeAt(index);

    await _updateApplicantInCollection('Training Position', student.uid);
    await _updateApplicantInCollection('Job Position', student.uid);

    notifyListeners();
  }

  Future<void> assignStudentToSupervisor(
      int applicantIndex, SupervisorModel supervisor) async {
    final student = filteredApplicants[applicantIndex];

    try {
      await _firebaseService.assignStudentToSupervisor(student.uid, supervisor);
      filteredApplicants.removeAt(applicantIndex);
      notifyListeners();
    } catch (e) {
      print("Failed to assign student to supervisor: $e");
    }
  }

  Future<void> _updateApplicantInCollection(
      String collectionName, String studentId) async {
    var snapshot = await _db.collection(collectionName).get();

    for (var doc in snapshot.docs) {
      if (doc.data()['studentApplicantsList'] != null &&
          (doc.data()['studentApplicantsList'] as List).contains(studentId)) {
        await _db.collection(collectionName).doc(doc.id).update({
          'studentApplicantsList': FieldValue.arrayRemove([studentId])
        });
      }
    }
  }
}
