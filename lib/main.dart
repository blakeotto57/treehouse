import 'package:flutter/material.dart';
import 'pages/home.dart'; // Your home page file
import 'user_setup.dart'; // Profile setup file
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
      initialRoute: '/',
      routes: {
        '/': (context) => CheckProfile(),
        '/home': (context) => HomePage(),
        '/profileSetup': (context) => ProfileSetupPage(),
      },
    );
  }
}

class CheckProfile extends StatefulWidget {
  @override
  _CheckProfileState createState() => _CheckProfileState();
}

class _CheckProfileState extends State<CheckProfile> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  void _checkProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');

    Future.delayed(Duration.zero, () {
      if (userName == null) {
        // If no profile is set, navigate to profile setup
        Navigator.pushReplacementNamed(context, '/profileSetup');
      } else {
        // If profile exists, navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
