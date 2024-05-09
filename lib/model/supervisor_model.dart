class Supervisor {
  final String name;
  final String email;

  Supervisor({
    required this.name,
    required this.email,
  });

  factory Supervisor.fromMap(Map<String, dynamic> map) {
    return Supervisor(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}