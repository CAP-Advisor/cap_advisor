
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
            name: doc['Name'],
            email: doc['Email'],
            password: doc['Password'],
          jobsList: List<String>.from(doc['JobsList']),
          userType: doc['userType']
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
          password: doc['Password'],
          name: doc['Name'],
          userType: doc['UserType'],
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
            name:doc['Name'],
            email:doc['Email'],
            password: doc['Password'],
            experiences:List<String>.from( doc['Experiences']),
            skills:List<String>.from(doc ['Skills']),
            feedback:doc['Feedback'],
            instructorId:doc['InstructorId'],
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
          name:doc ['name'],
          email:doc ['Email'],
          password: doc['Password'],
          studentList:List<String>.from (doc['StudentList']),
        );
      }).toList();
    }catch(e){
      print('Error getting Supervisor data: $e');
      return [];    }
  }

}
