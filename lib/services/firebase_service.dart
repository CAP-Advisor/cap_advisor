
import 'package:cap_advisor/model/student_model.dart';
import 'package:cap_advisor/model/supervisor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/HR_model.dart';
import '../model/instructor_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<HR>> getHRData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('HR').get();
      return querySnapshot.docs.map((doc) {
        return HR(
          companyName: doc['CompanyName'],
          email: doc['Email'],
          jobsList: List<String>.from(doc['JobsList']),
          name: doc['Name'],
        );
      }).toList();
    } catch (e) {
      print('Error getting HR data: $e');
      return [];
    }
  }

  Future<List<Instructor>> getInstructorData() async{
    try{
      QuerySnapshot querySnapshot = await _firestore.collection('Instructor').get();
      return querySnapshot.docs.map((doc) {
        return Instructor (
          email : doc['Email'],
          name: doc['Name'],
          studentList:List<String>.from( doc['StudentList']),
        );
      }).toList();
    }catch (e){
      print('Error getting Instructor data: $e');
      return [];
    }
  }

  Future<List<Student>> getStudentData() async{
    try{
      QuerySnapshot querySnapshot= await _firestore.collection('Student').get();
      return querySnapshot.docs.map((doc) {
        return Student(
            experiences:List<String>.from( doc['Experiences']),
            feedback:doc['Feedback'],
            instructorId:doc['InstructorId'], name:doc['Name'], skills:List<String>.from(doc ['Skills']),
            supervisorId:doc ['SupervisorId']);
      }).toList();
    }catch (e){
      print('Error getting Instructor data: $e');
      return [];
    }
  }
  Future<List<Supervisor>> getSupervisorData() async{
    try{
      QuerySnapshot querySnapshot =await _firestore.collection('Supervisor').get();
      return querySnapshot.docs.map((doc) {
        return Supervisor(
            companyName:doc ['CompanyName'],
            email:doc ['Email'],
            name:doc ['name'],
            studentList:List<String>.from (doc['StudentList'])
        );
      }).toList();
    }catch(e){
      print('Error getting Supervisor data: $e');
      return [];    }
  }
}
