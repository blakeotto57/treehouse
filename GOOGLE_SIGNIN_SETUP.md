# Google Sign-In Setup Guide for Flutter Web

This guide will walk you through setting up Google Sign-In for your Flutter web application.

## Prerequisites

- A Firebase project (already set up: `treehouse-c06f8`)
- Firebase Authentication enabled
- Google Sign-In provider enabled in Firebase

## Step-by-Step Setup Instructions

### Step 1: Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **treehouse-c06f8**
3. Navigate to **Authentication** > **Sign-in method**
4. Find **Google** in the list of sign-in providers
5. Click on **Google** and toggle **Enable**
6. Set a **Project support email** (use your email or a team email)
7. Click **Save**

### Step 2: Get Your Web Client ID

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Find your **Web app** (appId: `1:545022405037:web:57e528a5489ca1c526d924`)
4. Look for the **Web client ID** - it should look like:
   ```
   545022405037-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com
   ```
5. **Copy this Web client ID** - you'll need it in the next step

### Step 3: Configure Authorized Domains

1. In Firebase Console, go to **Authentication** > **Settings**
2. Scroll to **Authorized domains**
3. Make sure the following domains are listed:
   - `localhost` (for local development)
   - `treehouse-c06f8.firebaseapp.com` (Firebase hosting)
   - Your custom domain (if you have one, e.g., `treehouseconnect.com`)
4. If you need to add a domain, click **Add domain** and enter it

### Step 4: Update Flutter Code with Web Client ID

After you get the Web client ID from Step 2, you need to update the code:

1. Open `lib/auth/register_page.dart`
2. Find the `_signInWithGoogle()` method
3. Update the `GoogleSignIn()` constructor to include the `clientId`:

```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: 'YOUR_WEB_CLIENT_ID_HERE', // Paste the Web client ID from Step 2
  scopes: ['email', 'profile'],
);
```

Replace `YOUR_WEB_CLIENT_ID_HERE` with the actual Web client ID you copied.

### Step 5: Test the Implementation

1. Run your Flutter web app:
   ```bash
   flutter run -d chrome
   ```

2. Navigate to the registration page
3. Click "Sign up with Google"
4. You should see the Google sign-in popup
5. Sign in with a Google account that has a .edu email

## Troubleshooting

### Error: "redirect_uri_mismatch"
- **Solution**: Make sure `localhost` is in the authorized domains in Firebase Console
- Check that you're using the correct Web client ID

### Error: "popup_closed_by_user"
- This is normal if the user closes the popup
- The code handles this gracefully

### Error: "access_denied"
- Make sure Google Sign-In is enabled in Firebase Console
- Check that the Web client ID is correct
- Verify authorized domains include your domain

### Google Sign-In popup doesn't appear
- Check browser console for errors
- Make sure you're not blocking popups
- Verify the Web client ID is correct
- Check that `google_sign_in` package is up to date in `pubspec.yaml`

## Additional Configuration (If Needed)

### For Production Deployment

1. When deploying to production, make sure to:
   - Add your production domain to authorized domains
   - Update the Web client ID if needed (should be the same)
   - Test the sign-in flow on the production domain

### For Custom Domains

If you're using a custom domain (e.g., `treehouseconnect.com`):

1. Add the domain to Firebase authorized domains
2. Make sure your domain is verified in Firebase
3. The Web client ID remains the same

## Testing Checklist

- [ ] Google Sign-In is enabled in Firebase Console
- [ ] Web client ID is copied and added to the code
- [ ] Authorized domains include `localhost` and your domain
- [ ] Code is updated with the Web client ID
- [ ] App runs without errors
- [ ] Google Sign-In button appears on the registration page
- [ ] Clicking the button opens Google sign-in popup
- [ ] Signing in with a .edu email works
- [ ] Non-.edu emails are rejected with appropriate error
- [ ] User is redirected to explore page after successful sign-in

## Need Help?

If you encounter any issues:
1. Check the browser console for error messages
2. Check Firebase Console > Authentication > Users to see if sign-ins are being attempted
3. Verify all steps above are completed
4. Check that your Firebase project has the correct permissions

