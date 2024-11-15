import 'package:cap_advisor/service/student_firebase_service.dart';
import 'package:flutter/material.dart';
import '../exceptions/custom_exception.dart';
import '../model/student_position_search_model.dart';

class StudentPositionSearchViewModel extends ChangeNotifier {
  final StudentFirebaseService _firestore = StudentFirebaseService();
  List<StudentPositionSearchModel> positions = [];
  List<StudentPositionSearchModel> filteredPositions = [];
  bool isLoading = false;

  Future<void> fetchPositions() async {
    isLoading = true;
    notifyListeners();
    try {
      positions = await _firestore.fetchPositions();
      filteredPositions = List.from(positions);
      notifyListeners();
    } catch (e) {
      throw CustomException('Error fetching positions: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForPosition(String positionId, String studentId) async {
    try {
      await _firestore.applyForPosition(positionId, studentId);
    } catch (e) {
      throw CustomException('Error fetching positions: $e');
    }
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
