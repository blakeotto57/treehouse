@echo off
echo Starting Flutter web in windowed mode...
echo.

REM Try to run Flutter web with Chrome in app mode
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-port=8080

pause

