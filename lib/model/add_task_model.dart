class TaskModel {
  final String title;
  final String description;
  final DateTime deadline;

  TaskModel({
    required this.title,
    required this.description,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'Task Title': title,
      'Task Description': description,
      'deadline': deadline,
    };
  }
}
