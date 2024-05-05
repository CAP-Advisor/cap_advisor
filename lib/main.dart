import 'package:cap_advisor/view-model/firebase_service.dart';
import 'package:cap_advisor/view/home_view.dart';
import 'package:flutter/material.dart';
import './view/reset_password_view.dart'; // Ensure the path is correct
import '../services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize(); // Call the initialization function
  runApp(MaterialApp(home: HomeView()));
}
