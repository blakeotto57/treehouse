# PowerShell script to run Flutter web in a windowed mode
# Option 1: Run Flutter web and open in Chrome app mode (windowed)

Write-Host "Starting Flutter web in windowed mode..." -ForegroundColor Green

# Check if Flutter is available
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterPath) {
    Write-Host "Flutter not found in PATH. Please:" -ForegroundColor Yellow
    Write-Host "1. Add Flutter to your PATH, OR" -ForegroundColor Yellow
    Write-Host "2. Run this from your Flutter SDK directory, OR" -ForegroundColor Yellow
    Write-Host "3. Use the full path to flutter.exe" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example: C:\src\flutter\bin\flutter run -d chrome --web-browser-flag '--app=http://localhost:PORT'" -ForegroundColor Cyan
    exit 1
}

# Run Flutter web
Write-Host "Launching Flutter web..." -ForegroundColor Green
flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-port=8080

# Alternative: If you want to specify a custom window size
# flutter run -d chrome --web-browser-flag "--app=http://localhost:8080" --web-browser-flag "--window-size=1200,800" --web-port=8080

