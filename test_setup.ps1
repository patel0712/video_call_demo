# Quick Test Setup Script for Video Calling Feature
# PowerShell version for Windows

Write-Host "🚀 Setting up Video Call Testing Environment..." -ForegroundColor Green

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>$null
    Write-Host "✅ Flutter detected" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Clean and get dependencies
Write-Host "📦 Cleaning and getting dependencies..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Check for common issues
Write-Host "🔍 Checking for potential issues..." -ForegroundColor Yellow

# Check if required dependencies are in pubspec.yaml
$pubspecContent = Get-Content pubspec.yaml -Raw

if ($pubspecContent -match "flutter_aws_chime") {
    Write-Host "✅ flutter_aws_chime dependency found" -ForegroundColor Green
} else {
    Write-Host "❌ flutter_aws_chime dependency missing from pubspec.yaml" -ForegroundColor Red
    Write-Host "   Add: flutter_aws_chime: ^1.0.0" -ForegroundColor Yellow
}

if ($pubspecContent -match "permission_handler") {
    Write-Host "✅ permission_handler dependency found" -ForegroundColor Green
} else {
    Write-Host "❌ permission_handler dependency missing from pubspec.yaml" -ForegroundColor Red
    Write-Host "   Add: permission_handler: ^11.0.1" -ForegroundColor Yellow
}

# Check if server IP is configured
$apiContent = Get-Content lib/src/comman/api.dart -Raw
if ($apiContent -match "192.168.20.115") {
    Write-Host "✅ Backend server IP configured" -ForegroundColor Green
} else {
    Write-Host "⚠️  Check backend server IP in lib/src/comman/api.dart" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🧪 Testing Instructions:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Start your backend server on: http://192.168.20.115:5000"
Write-Host "2. Ensure your server has a /join endpoint"
Write-Host "3. Run the app on two devices:"
Write-Host ""
Write-Host "   Device 1: flutter run" -ForegroundColor Green
Write-Host "   Device 2: flutter run -d <device-id>" -ForegroundColor Green
Write-Host ""
Write-Host "4. In the app:"
Write-Host "   - Navigate to Dashboard"
Write-Host "   - Tap 'Video Call' card"
Write-Host "   - Use meeting ID: 'test-meeting-123'"
Write-Host "   - Device 1: Name 'Alice'"
Write-Host "   - Device 2: Name 'Bob'"
Write-Host ""
Write-Host "5. Expected behavior:"
Write-Host "   - Both devices connect to the same meeting"
Write-Host "   - Video/audio should work between devices"
Write-Host ""
Write-Host "🐛 Debugging:" -ForegroundColor Cyan
Write-Host "=============" -ForegroundColor Cyan
Write-Host "- Check console logs for API responses"
Write-Host "- Verify network connectivity to backend"
Write-Host "- Ensure camera/microphone permissions are granted"
Write-Host ""
Write-Host "📁 Key files to check:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "- lib/src/comman/api.dart (server URL)"
Write-Host "- lib/src/data/datasource/video_call_remote_data_source.dart"
Write-Host "- lib/src/presentation/page/video_call/video_call_screen.dart"
Write-Host ""

# Run analyzer to check for errors
Write-Host "🔧 Running Flutter analyzer..." -ForegroundColor Yellow
$analyzeResult = flutter analyze --no-fatal-infos

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ No critical analyzer issues found" -ForegroundColor Green
} else {
    Write-Host "⚠️  Please fix analyzer issues before testing" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Setup complete! Ready for testing." -ForegroundColor Green
Write-Host "💡 Tip: Use 'flutter devices' to see available devices for testing" -ForegroundColor Cyan