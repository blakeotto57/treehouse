@echo off
echo Starting Flutter in Chrome Debug Mode...
echo.

REM Add Flutter to PATH for this session if needed
set PATH=%PATH%;C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin

REM Run Flutter web in debug mode (debug is default)
flutter run -d chrome --web-port=8080

pause

