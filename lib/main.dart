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
      onGenerateRoute: (settings) {
        // Handle /post/ routes
        if (settings.name != null && settings.name!.startsWith('/post/')) {
          final postId = settings.name!.substring('/post/'.length);
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args['categoryColor'] != null && args['firestoreCollection'] != null) {
            return PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => UserPostPage(
                postId: postId,
                categoryColor: args['categoryColor'],
                firestoreCollection: args['firestoreCollection'],
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              settings: settings,
            );
          }
        }
        
        // Handle all other routes with zero-duration transitions
        Widget? page;
        switch (settings.name) {
          case '/login':
            page = LoginPage(onTap: () {});
            break;
          case '/register':
            page = RegisterPage(onTap: () {});
            break;
          case '/explore':
            page = ExplorePage();
            break;
          case '/messages':
            page = MessagesPage();
            break;
          case '/profile':
            page = UserProfilePage();
            break;
          case '/settings':
            page = const UserSettingsPage();
            break;
          case '/feedback':
            page = FeedbackPage();
            break;
          case '/category/personal-care':
            page = PersonalCarePage();
            break;
          case '/category/academics':
            page = AcademicsSellersPage();
            break;
          case '/category/cleaning':
            page = CleaningSellersPage();
            break;
          case '/category/errands-moving':
            page = ErrandsMovingSellersPage();
            break;
          case '/category/food':
            page = FoodSellersPage();
            break;
          case '/category/pet-care':
            page = PetCareSellersPage();
            break;
          case '/category/photography':
            page = PhotographySellersPage();
            break;
          case '/category/technical-services':
            page = TechnicalServicesSellersPage();
            break;
        }
        
        if (page != null) {
          return PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => page!,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            settings: settings,
          );
        }
        
        return null;
      },
      // Optional: define initial route
      initialRoute: '/',
    );
  }
}
