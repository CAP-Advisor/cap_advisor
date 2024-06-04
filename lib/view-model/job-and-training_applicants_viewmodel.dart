import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/student_model.dart';
import '../model/supervisor_model.dart';

class JobAndTrainingApplicantsViewModel extends ChangeNotifier {
  List<Student> applicants = [];
  List<SupervisorModel> supervisors = [];
  List<Student> filteredApplicants = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String hrDocumentId;

  JobAndTrainingApplicantsViewModel({
    required this.hrDocumentId,
    required String positionId,
    required String positionType,
  }) {
    fetchApplicants(positionId, positionType);
    fetchSupervisors();
  }

  String filterType = '';
  String filterValue = '';

  void applyFilter() {
    if (filterType.isNotEmpty && filterValue.isNotEmpty) {
      switch (filterType) {
        case 'gpa':
          filteredApplicants = applicants.where((applicant) {
            return applicant.gpa.toString().toLowerCase().contains(filterValue.toLowerCase());
          }).toList();
          break;
        case 'address':
          filteredApplicants = applicants.where((applicant) {
            return applicant.address.toLowerCase().contains(filterValue.toLowerCase());
          }).toList();
          break;
        case 'skill':
          filteredApplicants = applicants.where((applicant) {
            return applicant.skills.any((skill) =>
                skill.toLowerCase().contains(filterValue.toLowerCase()));
          }).toList();
          break;
        default:
          filteredApplicants = List.from(applicants);
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
    var positionSnapshot = await _db.collection(positionType).doc(positionId).get();
    if (positionSnapshot.exists) {
      var studentIds = List<String>.from(positionSnapshot.get('studentApplicantsList') ?? []);
      if (studentIds.isNotEmpty) {
        var studentSnapshot = await _db
            .collection('Student')
            .where(FieldPath.documentId, whereIn: studentIds)
            .get();
        applicants = studentSnapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      } else {
        applicants = [];
      }
      filteredApplicants = List.from(applicants);
      notifyListeners();
    }
  }

  Future<void> fetchSupervisors() async {
    var hrDoc = await _db.collection('HR').doc(hrDocumentId).get();
    if (hrDoc.exists) {
      var hrId = hrDoc.id;
      var snapshot = await _db
          .collection('Supervisor')
          .where('hrId', isEqualTo: hrId)
          .get();
      supervisors = snapshot.docs.map((doc) => SupervisorModel.fromFirestore(doc)).toList();
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
    final student = filteredApplicants[index];
    await _showSupervisorSelectionDialog(context, index);

    final url = Uri.parse('https://pacific-chamber-78827-0f1d28754b89.herokuapp.com/send-notification');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': student.uid,
        'title': 'Application Approved',
        'message': 'Congratulations! Your application has been approved.',
      }),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
    notifyListeners();
  }

  Future<void> rejectApplicant(int index) async {
    final student = filteredApplicants[index];
    applicants.removeWhere((applicant) => applicant.uid == student.uid);
    filteredApplicants.removeAt(index);

    await _updateApplicantInCollection('Training Position', student.uid);
    await _updateApplicantInCollection('Job Position', student.uid);

    final url = Uri.parse('https://pacific-chamber-78827-0f1d28754b89.herokuapp.com/send-notification');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': student.uid,
        'title': 'Application Rejected',
        'message': 'We regret to inform you that your application has been rejected.',
      }),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
    notifyListeners();
  }

  Future<void> _showSupervisorSelectionDialog(BuildContext context, int applicantIndex) async {
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
                    _assignStudentToSupervisor(applicantIndex, supervisor).then((_) {
                      Navigator.of(context).pop();
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _assignStudentToSupervisor(int applicantIndex, SupervisorModel supervisor) async {
    final student = filteredApplicants[applicantIndex];
    final supervisorRef = _db.collection('Supervisor').doc(supervisor.uid);

    try {
      await supervisorRef.update({
        'studentList': FieldValue.arrayUnion([student.uid])
      });
      notifyListeners();
    } catch (e) {
      print("Failed to assign student to supervisor: $e");
    }
  }

  Future<void> _updateApplicantInCollection(String collectionName, String studentId) async {
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
