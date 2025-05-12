import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/pages/home.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:treehouse/auth/auth.dart';
import 'package:treehouse/pages/login_page.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'firebase_options.dart'; // Firebase options (you need to configure this from Firebase console)
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures widget binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase with options
  );
  
  // Only activate App Check on non-web platforms
  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug, // Use .playIntegrity for production
    );
  }

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
      title: 'Your App Name',
      // Define your routes here
      routes: {
        '/login': (context) => LoginPage(onTap: () {},),
        '/settings': (context) => const UserSettingsPage(),
        // ...other routes...
      },
      // Optional: define initial route
      initialRoute: '/',
    );
  }
}