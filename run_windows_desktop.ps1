# PowerShell script to run Flutter as Windows Desktop App

Write-Host "Running Flutter as Windows Desktop App..." -ForegroundColor Green

# Check if Flutter is available
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterPath) {
    Write-Host "Flutter not found in PATH." -ForegroundColor Yellow
    Write-Host "Please add Flutter to your PATH or use full path to flutter.exe" -ForegroundColor Yellow
    exit 1
}

# Enable Windows desktop support
Write-Host "Ensuring Windows desktop support is enabled..." -ForegroundColor Green
flutter config --enable-windows-desktop

# Run as Windows app
Write-Host "Launching Windows desktop app..." -ForegroundColor Green
flutter run -d windows

# Note: For release build, use:
# flutter build windows
# Then run: build\windows\runner\Release\treehouse.exe

