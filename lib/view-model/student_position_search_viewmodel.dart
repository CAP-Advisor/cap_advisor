import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/student_position_search_model.dart';

class StudentPositionSearchViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<StudentPositionSearchModel> positions = [];
  List<StudentPositionSearchModel> filteredPositions = [];

  Future<List<StudentPositionSearchModel>> fetchPositions() async {
    try {
      QuerySnapshot jobSnapshot =
          await _firestore.collection('Job Position').get();
      QuerySnapshot trainingSnapshot =
          await _firestore.collection('Training Position').get();

      List<StudentPositionSearchModel> jobPositions =
          jobSnapshot.docs.map((doc) {
        return StudentPositionSearchModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id, 'Job Position');
      }).toList();

      List<StudentPositionSearchModel> trainingPositions =
          trainingSnapshot.docs.map((doc) {
        return StudentPositionSearchModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id, 'Training Position');
      }).toList();

      positions = [...jobPositions, ...trainingPositions];
      filteredPositions = List.from(positions);

      return positions;
    } catch (e) {
      print("Error fetching positions: $e");
      throw e;
    }
  }

  Future<void> applyForPosition(String positionId, String studentId) async {
    bool applied =
        await _applyToCollection('Job Position', positionId, studentId);
    if (!applied) {
      await _applyToCollection('Training Position', positionId, studentId);
    }
  }

  Future<bool> _applyToCollection(
      String collectionName, String positionId, String studentId) async {
    try {
      final positionRef = _firestore.collection(collectionName).doc(positionId);
      DocumentSnapshot positionDoc = await positionRef.get();

      if (positionDoc.exists) {
        await positionRef.update({
          'studentApplicantsList': FieldValue.arrayUnion([studentId])
        });
        return true;
      }
    } catch (e) {
      print("Error applying to $collectionName: $e");
    }
    return false;
  }

  void filterPositionsByTitle(String query) {
    if (query.isEmpty) {
      filteredPositions = List.from(positions);
    } else {
      filteredPositions = positions.where((position) {
        final contains =
            position.title.toLowerCase().contains(query.toLowerCase());
        print('Position ${position.title} contains "$query": $contains');
        return contains;
      }).toList();
    }
  }
}
