import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:treehouse/auth/auth.dart';
import 'firebase_options.dart'; // Firebase options (you need to configure this from Firebase console)

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures widget binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase with options
  );
  Stripe.publishableKey = 'pk_live_51QHBkvBXZFp1JN2DdxxjGMSu0araZivIpZSiOV8ZlWfUtTDjIXzWjR0mrrzhdnlIxf9A9Rjz8UJSoovzYgw1QfkP001opcNLtQ';
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  ); // Run the app after Firebase is initialized
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData, // Use the theme from ThemeProvider
      home: const AuthPage(),
    );
  }
}