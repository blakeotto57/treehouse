import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/auth/register_page.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/theme/theme_provider.dart';
import 'package:treehouse/auth/auth.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/feedback.dart';
import 'package:treehouse/category_pages/personal_care.dart';
import 'package:treehouse/category_pages/academics.dart';
import 'package:treehouse/category_pages/cleaning.dart';
import 'package:treehouse/category_pages/errands_moving.dart';
import 'package:treehouse/category_pages/food.dart';
import 'package:treehouse/category_pages/pet_care.dart';
import 'package:treehouse/category_pages/photography.dart';
import 'package:treehouse/category_pages/technical_services.dart';
import 'firebase_options.dart'; // Firebase options (you need to configure this from Firebase console)
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:treehouse/models/user_post_page.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode(fontFamily: "Helvetica"),
      darkTheme: darkMode(fontFamily: "Helvetica"),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthPage(),
      title: 'Treehouse',
      // Define comprehensive routes for page-specific URLs
      routes: {
        // Auth routes
        '/login': (context) => LoginPage(onTap: () {}),
        '/register': (context) => RegisterPage(onTap: () {}),
        
        // Main app routes
        '/explore': (context) => ExplorePage(),
        '/messages': (context) => MessagesPage(),
        '/profile': (context) => UserProfilePage(),
        '/settings': (context) => const UserSettingsPage(),
        '/feedback': (context) => FeedbackPage(),
        
        // Category routes
        '/category/personal-care': (context) => PersonalCarePage(),
        '/category/academics': (context) => AcademicsSellersPage(),
        '/category/cleaning': (context) => CleaningSellersPage(),
        '/category/errands-moving': (context) => ErrandsMovingSellersPage(),
        '/category/food': (context) => FoodSellersPage(),
        '/category/pet-care': (context) => PetCareSellersPage(),
        '/category/photography': (context) => PhotographySellersPage(),
        '/category/technical-services': (context) => TechnicalServicesSellersPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/post/')) {
          final postId = settings.name!.substring('/post/'.length);
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args['categoryColor'] != null && args['firestoreCollection'] != null) {
            return MaterialPageRoute(
              builder: (context) => UserPostPage(
                postId: postId,
                categoryColor: args['categoryColor'],
                firestoreCollection: args['firestoreCollection'],
              ),
              settings: settings,
            );
          }
        }
        return null;
      },
      // Optional: define initial route
      initialRoute: '/',
    );
  }
}
