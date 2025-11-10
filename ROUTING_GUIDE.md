# URL Routing Guide for Treehouse Connect

## How Your Routing System Works

Your Flutter web app uses **client-side routing**, which means different URLs (like `/about`, `/help`, `/terms`) show different pages without full page reloads. This is similar to how Reddit and other modern web apps work.

## Current Routes

Your app currently has these URL routes:

### Public Routes
- `/` or `/home` - Landing page (InitialPage)
- `/login` - Login page
- `/register` - Register page
- `/about` - About page ✨ **NEW**
- `/help` - Help/FAQ page ✨ **NEW**
- `/terms` - Terms of Service page ✨ **NEW**

### Authenticated Routes
- `/explore` - Main explore page
- `/messages` - Messages page
- `/profile` - User profile page
- `/settings` - User settings page
- `/feedback` - Feedback page

### Category Routes
- `/category/personal-care` - Personal care services
- `/category/academics` - Academic services
- `/category/cleaning` - Cleaning services
- `/category/errands-moving` - Errands and moving
- `/category/food` - Food services
- `/category/pet-care` - Pet care services
- `/category/photography` - Photography services
- `/category/technical-services` - Technical services

### Dynamic Routes
- `/post/{postId}` - Individual post pages

## How to Add New Routes

### Step 1: Create a New Page
Create a new file in `lib/pages/` (e.g., `lib/pages/privacy_page.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:treehouse/components/landing_header.dart';
import 'package:treehouse/theme/theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Your page content here
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const LandingHeader(showRightButton: false),
            // Your content
          ],
        ),
      ),
    );
  }
}
```

### Step 2: Import the Page in `lib/main.dart`
```dart
import 'package:treehouse/pages/privacy_page.dart';
```

### Step 3: Add the Route in `onGenerateRoute`
In `lib/main.dart`, add a new case in the switch statement:

```dart
case '/privacy':
  page = const PrivacyPage();
  break;
```

### Step 4: Create Navigation Links
You can now navigate to this route from anywhere in your app:

```dart
Navigator.pushNamed(context, '/privacy');
```

Or create a link in your footer/header:
```dart
GestureDetector(
  onTap: () => Navigator.pushNamed(context, '/privacy'),
  child: Text('Privacy Policy'),
)
```

## How It Works When Deployed

Your `firebase.json` file already has the correct configuration:

```json
{
  "rewrites": [
    {
      "source": "**",
      "destination": "/index.html"
    }
  ]
}
```

This tells Firebase Hosting to serve `index.html` for ALL routes. When someone visits `treehouseconnect.com/about`, Firebase serves `index.html`, and then Flutter's routing system (defined in `lib/main.dart`) determines which page to show based on the URL path.

## Example: Adding a "Contact" Page

1. **Create** `lib/pages/contact_page.dart`
2. **Add import** to `lib/main.dart`: `import 'package:treehouse/pages/contact_page.dart';`
3. **Add route** in `onGenerateRoute`:
   ```dart
   case '/contact':
     page = const ContactPage();
     break;
   ```
4. **Add link** to your footer in `landing_page.dart`
5. **Deploy** - The route will work automatically at `treehouseconnect.com/contact`

## SEO and Search Engine Indexing

To help search engines (like Google) discover and index your pages:

1. **Meta descriptions**: Already set in `web/index.html`
2. **Sitemap**: You can create a `sitemap.xml` file listing all your routes
3. **Structured data**: Add JSON-LD structured data for better search results

## Testing Routes Locally

When running locally, you can test routes by:
- Direct navigation: `Navigator.pushNamed(context, '/about')`
- Browser URL bar: `http://localhost:8080/about`
- Direct links in your UI (footer, header, etc.)

All routes work the same way locally and in production!

