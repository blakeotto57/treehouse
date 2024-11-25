import 'package:flutter/material.dart';
import 'package:treehouse/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebase options (you need to configure this from Firebase console)

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures widget binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase with options
  );
  runApp(MyApp()); // Run the app after Firebase is initialized
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "expressway"), // Custom font if added
      home: AuthPage(),
    );
  }
}