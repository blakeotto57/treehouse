import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treehouse/auth/login_page.dart';
import 'package:treehouse/auth/register_page.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'package:treehouse/pages/user_profile.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/explore_page.dart';
import 'package:treehouse/pages/feedback.dart';
import 'package:treehouse/pages/landing_page.dart';
import 'package:treehouse/pages/initial_page.dart';
import 'package:treehouse/pages/about_page.dart';
import 'package:treehouse/pages/help_page.dart';
import 'package:treehouse/pages/terms_page.dart';
import 'package:treehouse/category_pages/personal_care.dart';
import 'package:treehouse/category_pages/academics.dart';
import 'package:treehouse/category_pages/cleaning.dart';
import 'package:treehouse/category_pages/errands_moving.dart';
import 'package:treehouse/category_pages/food.dart';
import 'package:treehouse/category_pages/pet_care.dart';
import 'package:treehouse/category_pages/photography.dart';
import 'package:treehouse/category_pages/technical_services.dart';
import 'package:treehouse/models/user_post_page.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/theme/theme.dart';

// Helper function to create routes without transitions
Page<T> noTransitionPage<T extends Object?>({
  required Widget child,
  LocalKey? key,
  String? name,
  Object? arguments,
  String? restorationId,
}) {
  return NoTransitionPage<T>(
    key: key,
    name: name,
    arguments: arguments,
    restorationId: restorationId,
    child: child,
  );
}

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // Home routes
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: const InitialPage(),
        ),
      ),
      GoRoute(
        path: '/home',
        redirect: (context, state) => '/',
      ),
      GoRoute(
        path: '/landing',
        name: 'landing',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: const LandingPage(),
        ),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: LoginPage(onTap: () {}),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: RegisterPage(onTap: () {}),
        ),
      ),

      // Main pages
      GoRoute(
        path: '/explore',
        name: 'explore',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: const ExplorePage(),
        ),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: MessagesPage(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: UserProfilePage(),
        ),
      ),
      // Other users' profile pages
      GoRoute(
        path: '/profile/:username',
        name: 'user-profile',
        pageBuilder: (context, state) {
          final username = state.pathParameters['username']!;
          return noTransitionPage(
            key: state.pageKey,
            child: OtherUsersProfilePage(username: username),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: const UserSettingsPage(),
        ),
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: FeedbackPage(),
        ),
      ),

      // Info pages
      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: const AboutPage(),
        ),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: const HelpPage(),
        ),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        pageBuilder: (context, state) => noTransitionPage(
          key: state.pageKey,
          child: const TermsPage(),
        ),
      ),

      // Category routes
      GoRoute(
        path: '/category/:categoryName',
        name: 'category',
        pageBuilder: (context, state) {
          final categoryName = state.pathParameters['categoryName']!;
          return noTransitionPage(
            key: state.pageKey,
            child: _getCategoryPage(categoryName),
          );
        },
      ),

      // Post routes - Bulletin posts (from explore page)
      GoRoute(
        path: '/post/:postId',
        name: 'post',
        pageBuilder: (context, state) {
          final postId = state.pathParameters['postId']!;
          // Bulletin posts always use bulletin_posts collection and primary green color
          return noTransitionPage(
            key: state.pageKey,
            child: UserPostPage(
              postId: postId,
              categoryColor: AppColors.primaryGreen,
              firestoreCollection: 'bulletin_posts',
            ),
          );
        },
      ),

      // Forum post routes - Category forum posts
      GoRoute(
        path: '/forum/:category/:postId',
        name: 'forum-post',
        pageBuilder: (context, state) {
          final categoryRoute = state.pathParameters['category']!;
          final postId = state.pathParameters['postId']!;
          final collection = getCollectionFromRoute(categoryRoute);
          final categoryColor = _getCategoryColor(categoryRoute);
          
          return noTransitionPage(
            key: state.pageKey,
            child: UserPostPage(
              postId: postId,
              categoryColor: categoryColor,
              firestoreCollection: collection,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static Widget _getCategoryPage(String categoryName) {
    switch (categoryName) {
      case 'personal-care':
        return PersonalCarePage();
      case 'academics':
        return AcademicsSellersPage();
      case 'cleaning':
        return CleaningSellersPage();
      case 'errands-moving':
        return ErrandsMovingSellersPage();
      case 'food':
        return FoodSellersPage();
      case 'pet-care':
        return PetCareSellersPage();
      case 'photography':
        return PhotographySellersPage();
      case 'technical-services':
        return TechnicalServicesSellersPage();
      default:
        return const InitialPage();
    }
  }

  static Color _getCategoryColor(String categoryRouteName) {
    switch (categoryRouteName) {
      case 'personal-care':
        return const Color.fromRGBO(178, 129, 243, 1);
      case 'academics':
        return const Color.fromRGBO(238, 138, 96, 1);
      case 'cleaning':
        return const Color.fromRGBO(191, 84, 210, 1);
      case 'errands-moving':
        return const Color.fromRGBO(255, 193, 7, 1);
      case 'food':
        return const Color.fromRGBO(90, 124, 239, 1);
      case 'pet-care':
        return const Color.fromRGBO(76, 175, 80, 1);
      case 'photography':
        return const Color.fromRGBO(40, 147, 134, 1);
      case 'technical-services':
        return const Color.fromRGBO(255, 64, 129, 1);
      default:
        return AppColors.primaryGreen;
    }
  }

  // Helper method to get category route name from collection
  static String getCategoryRouteName(String firestoreCollection) {
    if (firestoreCollection == 'personal_care_posts') return 'personal-care';
    if (firestoreCollection == 'academic_posts') return 'academics';
    if (firestoreCollection == 'cleaning_posts') return 'cleaning';
    if (firestoreCollection == 'errands_moving_posts') return 'errands-moving';
    if (firestoreCollection == 'food_posts') return 'food';
    if (firestoreCollection == 'pet_care_posts') return 'pet-care';
    if (firestoreCollection == 'photography_posts') return 'photography';
    if (firestoreCollection == 'technical_posts') return 'technical-services';
    return firestoreCollection;
  }

  // Helper method to get collection name from route name
  static String getCollectionFromRoute(String routeName) {
    switch (routeName) {
      case 'personal-care':
        return 'personal_care_posts';
      case 'academics':
        return 'academic_posts';
      case 'cleaning':
        return 'cleaning_posts';
      case 'errands-moving':
        return 'errands_moving_posts';
      case 'food':
        return 'food_posts';
      case 'pet-care':
        return 'pet_care_posts';
      case 'photography':
        return 'photography_posts';
      case 'technical-services':
        return 'technical_posts';
      default:
        return routeName;
    }
  }
}

