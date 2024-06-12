class PostPositionModel {
  String? _positionType;
  String? _positionTitle;
  List<String>? _skillList;
  String? _positionDescription;

  PostPositionModel({
    String? positionType,
    String? positionTitle,
    List<String>? skillList,
    String? positionDescription,
  }):_positionType=positionType,
        _positionTitle=positionTitle,
        _skillList=skillList,
        _positionDescription=positionDescription;

  String? get positionType => _positionType;

  String? get positionDescription => _positionDescription;

  List<String>? get skillList => _skillList;

  String? get positionTitle => _positionTitle;



  set positionDescription(String? value) {
    _positionDescription = value;
  }


  set skillList(List<String>? value) {
    _skillList = value;
  }


  set positionTitle(String? value) {
    _positionTitle = value;
  }

  set positionType(String? value) {
    _positionType = value;
  }
}
