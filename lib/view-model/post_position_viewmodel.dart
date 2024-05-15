import 'package:cap_advisor/model/post_position_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostPositionViewModel {
  PostPositionModel model = PostPositionModel();

  String? get positionType => model.positionType;

  void setPositionType(String positionType) {
    model.positionType = positionType;
  }

  void setPositionTitle(String positionTitle) {
    model.positionTitle = positionTitle;
  }

  void setPositionSkills(List<String>? skillList) {
    model.skillList = skillList;
  }

  void setPositionDescription(String positionDescription) {
    model.positionDescription = positionDescription;
  }

  Future<void> savePosition(String positionTitle, String positionDescription,
      List<String>? skills, String hrId) async {
    String positionType = model.positionType ?? '';
    model.positionTitle = positionTitle;
    model.positionDescription = positionDescription;
    model.skillList = skills;
    String? collectionName;

    try {
      if (model.positionType == "Job Position")
        collectionName = model.positionType;
      else if (model.positionType == 'Training Position')
        collectionName = model.positionType;
      collectionName ??= '';
      positionTitle ??= '';
      positionDescription ?? '';
      await FirebaseFirestore.instance.collection(collectionName).add({
        'title': model.positionTitle,
        'description': model.positionDescription,
        'skills': model.skillList,
        'hrId': hrId, // Add HR ID field
      });
      // Reset model fields after saving
      model.positionTitle = '';
      model.positionDescription = '';
      model.skillList = [];
    } catch (error) {
      // Handle error
      print('Failed to save position: $error');
      rethrow; // Rethrow the error for handling in the view
    }
  }

  bool isValidDescription() {
    return model.positionDescription != null && model.positionDescription!.isNotEmpty;
  }

  bool isValidTitle() {
    return model.positionTitle != null && model.positionTitle!.isNotEmpty;
  }

  bool isValidPositionType() {
    return model.positionType != null && model.positionType!.isNotEmpty;
  }
}