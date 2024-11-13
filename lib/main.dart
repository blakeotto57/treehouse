import 'package:flutter/material.dart';
import 'pages/home.dart'; // Your home page file
import 'profile_setup.dart'; // Profile setup file
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

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
        Navigator.pushReplacementNamed(context, '/profileSetup');
      } else {
        Navigator.pushReplacementNamed(context, '/home');//ALWAYS MAKES YOUR RUN THE PROFILE SETUP EACH TIME, CHANGE TO "/home" IN ORDER TO AVE IT AND SKKIP PROCESS
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
