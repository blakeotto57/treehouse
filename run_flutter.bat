@echo off
REM This batch file adds Flutter to PATH for this session and runs Flutter
set PATH=%PATH%;C:\Users\blake\Downloads\flutter_windows_3.35.7-stable\flutter\bin

echo Flutter PATH added to this session
echo.

REM Test Flutter
flutter --version
echo.

REM Check if we're in the project directory
if not exist "pubspec.yaml" (
    echo Changing to project directory...
    cd /d "C:\Users\blake\treehouse-1"
)

echo.
echo ========================================
echo   What would you like to do?
echo ========================================
echo 1. Run Flutter web (windowed Chrome)
echo 2. Run Flutter Windows desktop app
echo 3. Run Flutter doctor (check setup)
echo 4. Get dependencies (flutter pub get)
echo 5. Exit
echo.
set /p choice="Enter choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo Starting Flutter web in windowed mode...
    flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-port=8080
) else if "%choice%"=="2" (
    echo.
    echo Running as Windows desktop app...
    flutter config --enable-windows-desktop
    flutter run -d windows
) else if "%choice%"=="3" (
    echo.
    flutter doctor
) else if "%choice%"=="4" (
    echo.
    flutter pub get
) else (
    echo Exiting...
    exit /b 0
)

pause


