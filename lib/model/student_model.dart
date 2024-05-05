class Student {
  String name;
  String email;
  String password;
  List<String> experiences;
  String feedback;
  String instructorId;
  List<String> skills;
  String supervisorId;

  Student({
    required this.name,
    required this.email,
    required this.password,
    required this.experiences,
    required this.skills,
    required this.feedback,
    required this.instructorId,
    required this.supervisorId,
  });
}