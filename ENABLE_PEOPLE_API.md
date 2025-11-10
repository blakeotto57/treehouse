# Enable Google People API - Quick Guide

The error you're seeing is because the **Google People API** needs to be enabled in your Google Cloud Console. This is required for Google Sign-In to retrieve user profile information.

## Steps to Enable People API:

### Option 1: Enable via the Error Link (Easiest)

1. Click on the link provided in the error message:
   ```
   https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=545022405037
   ```

2. Click the **"Enable"** button

3. Wait 2-3 minutes for the API to activate

4. Try signing in with Google again

### Option 2: Enable via Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: **treehouse-c06f8** (Project ID: 545022405037)
3. Navigate to **APIs & Services** > **Library**
4. Search for **"People API"**
5. Click on **"Google People API"**
6. Click the **"Enable"** button
7. Wait 2-3 minutes for the API to activate

## After Enabling:

1. **Restart your Flutter app**
2. Try signing up with Google again
3. The .edu email validation should now work correctly

## Important Notes:

- The API activation can take a few minutes to propagate
- You may need to wait 2-5 minutes after enabling before it works
- Once enabled, the error should disappear and you'll be able to test the .edu validation

## Testing the .edu Validation:

After the People API is enabled:

1. Sign up with a **non-.edu email** (e.g., gmail.com)
   - You should see: **"You need to sign up with a .edu email address."**

2. Sign up with a **.edu email** (e.g., student@university.edu)
   - You should be successfully signed in and redirected to the explore page

## Alternative Solution (If People API Still Causes Issues):

If you continue to have issues with the People API, the code has been updated to:
- Only request the 'email' scope (not 'profile')
- Get the email from Firebase Auth (which doesn't require People API)
- This should work even if People API has issues

However, enabling the People API is still recommended for the best user experience.

