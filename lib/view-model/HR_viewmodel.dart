import 'package:cap_advisor/model/firebaseuser.dart';
import 'package:cap_advisor/model/job_model.dart';
import 'package:cap_advisor/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/HR_model.dart';
import '../service/hr_firebase_serviece.dart';
import '../view/job-and-training_applicants_view.dart';

enum PositionType {
  job,
  training,
}

class HRViewModel extends ChangeNotifier {
  PositionType currentType = PositionType.job;
  final HRFirebaseService _firebaseService = HRFirebaseService();
  TextEditingController searchController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  List<Job> allPositions = [];
  List<Job> filteredPositions = [];
  bool isLoading = true;
  String? errorMessage;
  FireBaseUser? user;
  HR? currentHR;
  String? error;
  String? get HRName => currentHR?.name;
  String? get HREmail => currentHR?.email;
  String? get HRPhotoUrl => currentHR?.photoUrl;

  HRViewModel() {
    fetchPositions();
    getHRDataByEmail();
  }

  Future<void> getHRDataByEmail() async {
    isLoading = true;
    notifyListeners();

    try {
      currentHR = await _firebaseService.getHRDataByEmail();
      if (currentHR == null) {
        error = "No hr data available.";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPositions() async {
    isLoading = true;
    notifyListeners();

    try {
      String collectionName = currentType == PositionType.job
          ? 'Job Position'
          : 'Training Position';
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      var positions =
          querySnapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();

      final User? user = firebaseAuth.currentUser;
      if (user != null) {
        positions = positions.where((job) => job.hrId == user.uid).toList();
      }

      allPositions = positions;
      filteredPositions = positions;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error fetching positions: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJob(Job job) async {
    isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteJob(job.id);
      allPositions.removeWhere((j) => j.id == job.id);
      filteredPositions.removeWhere((j) => j.id == job.id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete job';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTraining(Job job) async {
    isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteTraining(job.id);
      allPositions.removeWhere((j) => j.id == job.id);
      filteredPositions.removeWhere((j) => j.id == job.id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete training';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateHRProfileImage() async {
    bool result = await _firebaseService.updateHRProfileImage();
    if (result) {
      print("Profile image updated successfully.");
    } else {
      print("Failed to update profile image.");
    }
    return result;
  }

  Future<bool> updateHRCoverPhoto() async {
    bool result = await _firebaseService.updateHRCoverPhoto();
    if (result) {
      print("Cover photo updated successfully.");
    } else {
      print("Failed to update cover photo.");
    }
    return result;
  }

  Future<void> handleProfileAction(BuildContext context, String value) async {
    switch (value) {
      case 'view_profile_photo':
        if (currentHR?.photoUrl != null) {
          _showImageDialog(context, currentHR!.photoUrl!, 'Profile Photo');
        }
        break;
      case 'view_cover_photo':
        if (currentHR?.coverPhotoUrl != null) {
          _showImageDialog(context, currentHR!.coverPhotoUrl!, 'Cover Photo');
        }
        break;
      case 'choose_profile_photo':
        var result = await updateHRProfileImage();
        _showSnackBar(context, result, 'Profile photo updated successfully!',
            'Failed to update profile photo.');
        break;
      case 'choose_cover_photo':
        var result = await updateHRCoverPhoto();
        _showSnackBar(context, result, 'Cover photo updated successfully!',
            'Failed to update cover photo.');
        break;
    }
  }

  void _showSnackBar(BuildContext context, bool result, String successMessage,
      String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? successMessage : errorMessage),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Image.network(
            imageUrl,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            fit: BoxFit.contain,
            width: double.maxFinite,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void editJobDescription(BuildContext context, Job job) {
    TextEditingController titleController =
        TextEditingController(text: job.title);
    TextEditingController descriptionController =
        TextEditingController(text: job.description);
    TextEditingController skillsController =
        TextEditingController(text: job.skills.join(', '));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Job Description'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: skillsController,
                  decoration:
                      InputDecoration(labelText: 'Skills (comma-separated)'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    primaryColor),
                foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white),
              ),
              onPressed: () {
                job.title = titleController.text;
                job.description = descriptionController.text;
                job.skills = skillsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList();
                String collectionName = currentType == PositionType.job
                    ? 'Job Position'
                    : 'Training';
                final documentReference = FirebaseFirestore.instance
                    .collection(collectionName)
                    .doc(job.id);

                documentReference.update(job.toMap()).then((_) {
                  notifyListeners();
                  print("Document successfully updated");
                }).catchError((error) {
                  print("Error updating document: $error");
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobAndTrainingApplicantsView(
                      hrDocumentId: job.hrId,
                      positionId: job.id, // Pass position ID
                      positionType: currentType == PositionType.job
                          ? 'Job Position'
                          : 'Training Position', // Pass position type
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void togglePositionType(PositionType type) {
    currentType = type;
    fetchPositions();
  }

  void searchPositions(String query) {
    filteredPositions = allPositions
        .where((pos) =>
            (pos.title.toLowerCase().contains(query.toLowerCase()) ||
                pos.description.toLowerCase().contains(query.toLowerCase())))
        .toList();
    notifyListeners();
  }
}
