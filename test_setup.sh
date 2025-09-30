#!/bin/bash
# Quick Test Setup Script for Video Calling Feature

echo "🚀 Setting up Video Call Testing Environment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter detected"

# Clean and get dependencies
echo "📦 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Check for common issues
echo "🔍 Checking for potential issues..."

# Check if required dependencies are in pubspec.yaml
if grep -q "flutter_aws_chime" pubspec.yaml; then
    echo "✅ flutter_aws_chime dependency found"
else
    echo "❌ flutter_aws_chime dependency missing from pubspec.yaml"
    echo "   Add: flutter_aws_chime: ^1.0.0"
fi

if grep -q "permission_handler" pubspec.yaml; then
    echo "✅ permission_handler dependency found"
else
    echo "❌ permission_handler dependency missing from pubspec.yaml"
    echo "   Add: permission_handler: ^11.0.1"
fi

# Check if server IP is configured
if grep -q "192.168.20.115" lib/src/comman/api.dart; then
    echo "✅ Backend server IP configured"
else
    echo "⚠️  Check backend server IP in lib/src/comman/api.dart"
fi

echo ""
echo "🧪 Testing Instructions:"
echo "========================"
echo ""
echo "1. Start your backend server on: http://192.168.20.115:5000"
echo "2. Ensure your server has a /join endpoint"
echo "3. Run the app on two devices:"
echo ""
echo "   Device 1: flutter run"
echo "   Device 2: flutter run -d <device-id>"
echo ""
echo "4. In the app:"
echo "   - Navigate to Dashboard"
echo "   - Tap 'Video Call' card"
echo "   - Use meeting ID: 'test-meeting-123'"
echo "   - Device 1: Name 'Alice'"
echo "   - Device 2: Name 'Bob'"
echo ""
echo "5. Expected behavior:"
echo "   - Both devices connect to the same meeting"
echo "   - Video/audio should work between devices"
echo ""
echo "🐛 Debugging:"
echo "============="
echo "- Check console logs for API responses"
echo "- Verify network connectivity to backend"
echo "- Ensure camera/microphone permissions are granted"
echo ""
echo "📁 Key files to check:"
echo "====================="
echo "- lib/src/comman/api.dart (server URL)"
echo "- lib/src/data/datasource/video_call_remote_data_source.dart"
echo "- lib/src/presentation/page/video_call/video_call_screen.dart"
echo ""

# Run analyzer to check for errors
echo "🔧 Running Flutter analyzer..."
flutter analyze --no-fatal-infos

if [ $? -eq 0 ]; then
    echo "✅ No critical analyzer issues found"
else
    echo "⚠️  Please fix analyzer issues before testing"
fi

echo ""
echo "🎉 Setup complete! Ready for testing."
echo "💡 Tip: Use 'flutter devices' to see available devices for testing"