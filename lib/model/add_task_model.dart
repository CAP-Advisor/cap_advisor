class TaskModel {
  final String title;
  final String description;
  final DateTime deadline;
  final String? supervisorName;

  TaskModel({
    required this.title,
    required this.description,
    required this.deadline,
    required this.supervisorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'Task Title': title,
      'Task Description': description,
      'deadline': deadline,
      'Supervisor Name': supervisorName,
    };
  }
}
