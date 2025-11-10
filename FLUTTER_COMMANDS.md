# Flutter Web Commands

## Launch Flutter Web in Browser Tab

### Basic Command (Opens in Chrome tab):
```bash
flutter run -d chrome
```

### With Custom Port:
```bash
flutter run -d chrome --web-port=8080
```

### Windowed Mode (No browser UI - looks like desktop app):
```bash
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-port=8080
```

### Windowed Mode with Custom Window Size:
```bash
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-browser-flag "--window-size=1400,900" --web-port=8080
```

## Quick Start

**Double-click:** `run_web.bat` to launch in a browser tab

## Available Devices

To see all available devices:
```bash
flutter devices
```

## Other Useful Commands

### Get Dependencies:
```bash
flutter pub get
```

### Check Flutter Setup:
```bash
flutter doctor
```

### Build for Web (production):
```bash
flutter build web
```

### Run with Hot Reload (already enabled):
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

## Troubleshooting

### If Flutter not found:
Use the full path or run `run_web.bat`:
```bash
C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin\flutter.bat run -d chrome
```

### Port already in use:
Change the port:
```bash
flutter run -d chrome --web-port=8081
```

