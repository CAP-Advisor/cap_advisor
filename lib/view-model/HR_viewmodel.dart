import 'dart:io';
import 'package:cap_advisor/model/firebaseuser.dart';
import 'package:cap_advisor/model/job_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../service/firebase_service.dart';
import '../view/job-and-training_applicants_view.dart';

enum ImageType {
  background,
  profile,
}

enum PositionType {
  job,
  training,
}

class HRViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  String profileImage = 'https://dummyimage.com/150/808080/000000';
  String backgroundImage = 'https://dummyimage.com/500x300/808080/000000';
  String bio = "I am working as HR in Superlink company for 10 years and am working as co-instructor";
  PositionType currentType = PositionType.job;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  List<Job> allPositions = [];
  List<Job> filteredPositions = [];
  bool isLoading = true;
  String? errorMessage;
  FirebaseStorage storage= FirebaseStorage.instance;
  FireBaseUser? user;


  HRViewModel() {
    fetchPositions();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    user = await getUserData();
    notifyListeners();
  }

  Future<FireBaseUser?> getUserData() async {
    User? authedUser = firebaseAuth.currentUser;
    if (authedUser == null) {
      errorMessage = "User is not authenticated.";
      return null;
    }

    try {
      FirebaseService service = FirebaseService();
      var userMap = await service.getUserData(authedUser.email);
      if (userMap != null) {
        return FireBaseUser.fromMap(userMap['userData']);
      } else {
        errorMessage = "User data not found.";
        return null;
      }
    } catch (e) {
      errorMessage = "Failed to get user data: $e";
      return null;
    }
  }

  Future<void> fetchPositions() async {
    isLoading = true;
    notifyListeners();

    try {
      String collectionName = currentType == PositionType.job ? 'Job Position' : 'Training Position';
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
      var positions = querySnapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();

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
  Future<String> fetchImageUrl({required ImageType type}) async {

      String userId = firebaseAuth.currentUser?.uid ?? '';
      String folderName = type == ImageType.background ? 'background' : 'profile';
      Reference folderRef = storage.ref('$userId/$folderName');

      ListResult result = await folderRef.listAll();
      if (result.items.isNotEmpty) {
        result.items.sort((a, b) => b.name.compareTo(a.name));
        String imageUrl = await result.items.last.getDownloadURL();

        return imageUrl;
      } else {
          return type == ImageType.background ? 'https://dummyimage.com/500x300/808080/000000' : 'https://dummyimage.com/150/808080/000000';
      }
  }


  Future<void> pickImage(ImageSource source, {required ImageType type}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      String folderName = type == ImageType.background ? 'background' : 'profile';
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = '$folderName/$timestamp.jpg';

      String userId = firebaseAuth.currentUser?.uid ?? '';
      Reference ref = storage.ref('$userId/$fileName');

      TaskSnapshot uploadTask = await ref.putFile(File(image.path));
      String fileURL = await uploadTask.ref.getDownloadURL();

      if (type == ImageType.background) {
        backgroundImage = fileURL;
      } else {
        profileImage = fileURL;
      }
      notifyListeners();
    } else {
      print('No image selected');
    }
  }



  void editBio(BuildContext context) {
    TextEditingController bioController = TextEditingController(text: bio);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Bio"),
          content: TextField(
            controller: bioController,
            decoration: InputDecoration(labelText: "Edit your bio"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                bio = bioController.text;
                notifyListeners();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void editJobDescription(BuildContext context, Job job) {
    TextEditingController titleController = TextEditingController(text: job.title);
    TextEditingController descriptionController = TextEditingController(text: job.description);
    TextEditingController skillsController = TextEditingController(text: job.skills.join(', ')); // Initialize skills controller

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
                  controller: skillsController, // Use skillsController
                  decoration: InputDecoration(labelText: 'Skills (comma-separated)'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF427D9D)), // Set the background color to #427D9D
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Set the text color to white
              ),
              onPressed: () {
                job.title = titleController.text;
                job.description = descriptionController.text;
                job.skills = skillsController.text.split(',').map((s) => s.trim()).toList();
                String collectionName = currentType == PositionType.job ? 'Job Position' : 'Training';
                final documentReference = FirebaseFirestore.instance.collection(collectionName).doc(job.id);

                documentReference.update(job.toMap()).then((_) {
                  notifyListeners();
                  print("Document successfully updated");
                }).catchError((error) {
                  print("Error updating document: $error");
                });

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  bool is_account_owner(String requiredId){
    User? user= firebaseAuth.currentUser;

    if(requiredId!=user?.uid){
      return false;
    }
    return true;
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
