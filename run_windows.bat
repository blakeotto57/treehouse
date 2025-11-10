@echo off
echo Running Flutter as Windows Desktop App...
echo.

REM Enable Windows desktop support
flutter config --enable-windows-desktop

REM Run as Windows app
flutter run -d windows

pause

