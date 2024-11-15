class JobAndTrainingApplicantsModel {
  final String name;
  final String email;
  List<String> studentApplicantsList;

  JobAndTrainingApplicantsModel({
    required this.name,
    required this.email,
    required this.studentApplicantsList,
  });

  factory JobAndTrainingApplicantsModel.fromFirestore(Map<String, dynamic> data) {
    return JobAndTrainingApplicantsModel(
      name: data['name'],
      email: data['email'],
      studentApplicantsList: List<String>.from(data['studentApplicantsList'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'studentApplicantsList': studentApplicantsList,
    };
  }
}
