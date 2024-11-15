import 'package:firebase_core/firebase_core.dart';

class FirebaseServices {
  static Future initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAQYRsFz0D1RzD693QMsmkzA645-pSQ1_c",
        authDomain: "cap-advisor-a1c2.firebaseapp.com",
        projectId: "cap-advisor-a1c2d",
        storageBucket: "cap-advisor-a1c2d.appspot.com",
        messagingSenderId: "1076600979829",
        appId: "1:1076600979829:android:eaa83474f8326c47b2933c",
      ),
    );
  }
}
