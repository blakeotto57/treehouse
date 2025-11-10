# Running Flutter Web in a Local Window

You have several options to run your Flutter web project in a windowed/local environment:

## Option 1: Chrome App Mode (Recommended for Web)

This runs your Flutter web app in Chrome but in a windowed mode without browser UI.

### Steps:
1. Make sure Flutter is in your PATH or use the full path
2. Run from your project directory:

```powershell
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-port=8080
```

### With Custom Window Size:
```powershell
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-browser-flag "--window-size=1200,800" --web-port=8080
```

### Using the PowerShell Script:
```powershell
.\run_windowed.ps1
```

## Option 2: Windows Desktop App

Run your Flutter app as a native Windows desktop application.

### Steps:
1. Ensure Windows desktop support is enabled:
```powershell
flutter config --enable-windows-desktop
```

2. Run as Windows app:
```powershell
flutter run -d windows
```

3. Or build for release:
```powershell
flutter build windows
```

The executable will be in: `build\windows\runner\Release\treehouse.exe`

## Option 3: Chrome Windowed Mode (Manual)

1. First, run Flutter web normally:
```powershell
flutter run -d chrome
```

2. Then, in Chrome:
   - Right-click on the Chrome tab
   - Select "Open in Chrome App" (if available)
   - Or manually create a shortcut to the URL with `--app` flag

## Option 4: Build and Serve Locally

1. Build the web app:
```powershell
flutter build web
```

2. Serve it locally using any HTTP server:
```powershell
# Using Python (if installed)
cd build/web
python -m http.server 8080

# Or using Node.js http-server
npx http-server build/web -p 8080
```

3. Open in Chrome with app mode:
```powershell
Start-Process chrome.exe --args "--app=http://localhost:8080"
```

## Recommended Setup

For development, I recommend **Option 1** (Chrome App Mode) as it:
- ✅ Runs in a clean window without browser UI
- ✅ Hot reload works perfectly
- ✅ Fastest development cycle
- ✅ No build step required

## Troubleshooting

### Flutter not found in PATH:
Add Flutter to your system PATH:
1. Find your Flutter installation (e.g., `C:\src\flutter\bin`)
2. Add it to Windows PATH environment variable
3. Restart your terminal

### Port already in use:
Change the port:
```powershell
flutter run -d chrome --web-port=8081
```

### Want a specific window size:
Use multiple browser flags:
```powershell
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-browser-flag "--window-size=1400,900" --web-port=8080
```

