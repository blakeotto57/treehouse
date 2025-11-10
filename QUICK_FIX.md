# Quick Fix - Flutter Not Working

## The Problem
Your PATH is set correctly in Windows, but your current terminal session hasn't picked it up.

## Immediate Solution

### Option 1: Use the Batch File (Easiest)
Double-click: **`run_flutter.bat`**

This will:
- Add Flutter to PATH for that session
- Let you choose what to do (run app, check setup, etc.)

### Option 2: Close and Reopen Terminal
1. **Close ALL PowerShell/Command Prompt windows**
2. **Open a NEW PowerShell or Command Prompt**
3. Navigate to your project:
   ```bash
   cd C:\Users\blake\treehouse-1
   ```
4. Test:
   ```bash
   flutter --version
   ```

### Option 3: Use Full Path (Works Immediately)
Instead of `flutter`, use the full path:

```bash
C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin\flutter.bat --version
```

Or create an alias in PowerShell:
```powershell
Set-Alias flutter "C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin\flutter.bat"
```

## Verify Your PATH is Correct

Run this in PowerShell:
```powershell
[Environment]::GetEnvironmentVariable("Path", "User")
```

You should see: `C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin`

If you don't see it, you need to:
1. Press `Win + R`
2. Type: `sysdm.cpl`
3. Click: **Environment Variables**
4. Under **User variables**, edit **Path**
5. Make sure you have: `C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin`
6. Click **OK** on all dialogs
7. **Close and reopen your terminal**

## Test Flutter is Working

Once Flutter works, try:
```bash
flutter doctor
flutter pub get
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-port=8080
```

## Still Not Working?

1. Make sure you extracted Flutter (not just the zip file)
2. Verify this file exists: `C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin\flutter.bat`
3. Restart your computer (sometimes needed for PATH changes)
4. Try using the batch file instead: `run_flutter.bat`


