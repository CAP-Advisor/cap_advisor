import 'package:cap_advisor/model/post_position_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../exceptions/custom_exception.dart';

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
        'hrId': hrId,
        'studentApplicantsList': [],
      });
      model.positionTitle = '';
      model.positionDescription = '';
      model.skillList = [];
    } catch (error) {
      throw CustomException('Failed to save position: $error');
    }
  }

  bool isValidDescription() {
    return model.positionDescription != null &&
        model.positionDescription!.isNotEmpty;
  }

  bool isValidTitle() {
    return model.positionTitle != null && model.positionTitle!.isNotEmpty;
  }

  bool isValidPositionType() {
    return model.positionType != null && model.positionType!.isNotEmpty;
  }
}
