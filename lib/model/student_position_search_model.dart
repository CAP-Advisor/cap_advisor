class StudentPositionSearchModel {
  final String id;
  final String title;
  final String description;
  final String hrId;
  final List<String> skills;
  final String positionType;
  final String companyName;

  StudentPositionSearchModel({
    required this.id,
    required this.title,
    required this.description,
    required this.hrId,
    required this.skills,
    required this.positionType,
    required this.companyName,
  });

  factory StudentPositionSearchModel.fromFirestore(
      Map<String, dynamic> data, String documentId, String positionType) {
    return StudentPositionSearchModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hrId: data['hrId'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      positionType: positionType,
      companyName: data['companyName'] ?? '',
    );
  }
}
