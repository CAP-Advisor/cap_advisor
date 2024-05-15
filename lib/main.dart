import 'package:cap_advisor/model/firebaseuser.dart';
import 'package:cap_advisor/service/firebase_service.dart';
import 'package:cap_advisor/utils/role_factory.dart';
import 'package:cap_advisor/view-model/add_task_viewmodel.dart';
import 'package:cap_advisor/view-model/assigning_feedback_viewmodel.dart';
import 'package:cap_advisor/view/HR_view.dart';
import 'package:cap_advisor/view/add_task_view.dart';
import 'package:cap_advisor/view/assigning_feedback_view.dart';
import 'package:cap_advisor/view/display_feedback_view.dart';
import 'package:cap_advisor/view/home_view.dart';
import 'package:cap_advisor/view/instructor_view.dart';
import 'package:cap_advisor/view/login_view.dart';
import 'package:cap_advisor/view/post_position_view.dart';
import 'package:cap_advisor/view/menu_view.dart';
import 'package:cap_advisor/view/sign_up_view.dart';
import 'package:cap_advisor/view/student_view.dart';
import 'package:cap_advisor/view/supervisor_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAQYRsFz0D1RzD693QMsmkzA645-pSQ1_c",
      authDomain: "cap-advisor-a1c2.firebaseapp.com",
      projectId: "cap-advisor-a1c2d",
      storageBucket: "cap-advisor-a1c2d.appspot.com",
      messagingSenderId: "1076600979829",
      appId: "1:1076600979829:android:eaa83474f8326c47b2933c",
    ),
  );

  FirebaseAuth auth = FirebaseAuth.instance;
  var user = auth.currentUser;
  bool isAuthenticated = user != null;

  String? userType;
  if (isAuthenticated) {
    FirebaseService firebaseService = FirebaseService();
    var userMap = await firebaseService.getUserData(user!.email!);
    if (userMap != null) {
      var userObj = FireBaseUser.fromMap(userMap);
      userType = userObj.userType;
    }
  }

  runApp(MyApp(
    isAuthenticated: isAuthenticated,
    userType: userType,
  ));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;
  final String? userType;

  const MyApp({Key? key, required this.isAuthenticated, this.userType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var homeView =isAuthenticated ? roleFactory(userType!) : HomeView();
    return MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => AssigningFeedbackViewModel()),

          // Add more providers if needed
    ],
    child: MaterialApp(
    title: 'CAP Advisor',
    theme: ThemeData(),
    home: AddTaskView(studentName: '', studentId: '',),
        routes: {
        '/login': (context) => LoginView(),
        '/SignUp': (context) => SignUpView(),
        '/HR': (context) => HRView(
          uid: '',
        ),
        '/Supervisor': (context) => SupervisorView(
              uid: '',
            ),
'/Instructor': (context) => InstructorView(
              uid: '',
            ),
        '/Student': (context) => StudentView(
              uid: '',
            ),
        '/home': (context) => HomeView(),
        'job-and-training-posting':(context)=> PostPositionView(),
        '/menu': (context) => MenuView(),
        '/assign-feedback':(context) => AssigningFeedbackView(),
          '/add-task':(context) => AddTaskView(studentId: '', studentName: ''),
      },
    ),
    );
  }
}