class HR {
  String companyName;
  String email;
  List<String>? jobsList;
  String name;
  String userType;
  String password;

  HR({
    required this.name,
    required this.companyName,
    required this.email,
    required this.password,
    this.jobsList,
    required this.userType,
  });
}
