import 'package:flutter/cupertino.dart';

import '../view/HR_view.dart';
import '../view/instructor_view.dart';
import '../view/student_view.dart';
import '../view/supervisor_view.dart';

Widget? roleFactory(String ?userType){
  switch (userType) {
    case 'HR':
      return HRView(
        uid: '',
      );
    case 'Supervisor':
      return SupervisorView(
        uid: '',
      );
    case 'Instructor':
      return InstructorView(
        uid: '',
      );
    case 'Student':
      return StudentView(
        uid: '',
      );

    default:
      return null;
  }
}
