import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:treehouse/theme/drawer_width_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:treehouse/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures widget binding is initialized

  // Use path URL strategy for cleaner URLs
  setUrlStrategy(PathUrlStrategy());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Initialize Firebase with options
  );

  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          AndroidProvider.debug, // Use .playIntegrity for production
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => DrawerWidthProvider()),
      ],
      child: const MyApp(),
    ),
  ); // Run the app after Firebase is initialized
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightMode(fontFamily: "Roboto"),
      darkTheme: darkMode(fontFamily: "Roboto"),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      title: 'Treehouse Connect • UCSC Marketplace',
      routerConfig: AppRouter.router,
    );
  }
}
