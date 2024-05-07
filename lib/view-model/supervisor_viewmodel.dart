import '../model/student_model.dart';
import '../service/firebase_service.dart';
import '../model/supervisor_model.dart';

class SupervisorViewModel {
  final FirebaseService _firestoreService = FirebaseService();

  Future<List<Student>> fetchStudents() async {
    return _firestoreService.fetchStudents();
  }
}
