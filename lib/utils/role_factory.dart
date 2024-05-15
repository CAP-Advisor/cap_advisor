import 'package:flutter/cupertino.dart';

import '../view/HR_view.dart';
import '../view/instructor_view.dart';
import '../view/student_view.dart';
import '../view/supervisor_view.dart';

StatelessWidget? roleFactory(String? userType) {
  switch (userType) {
    case 'HR':
      return HRView();
    case 'Supervisor':
      return SupervisorView(
        uid: '',
      );
    case 'Instructor':
      return InstructorView();
    case 'Student':
      return StudentView(
        uid: '',
      );

    default:
      return null;
  }
}
