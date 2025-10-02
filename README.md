# VideoCall - Flutter Video Calling App

A Flutter application with AWS Chime SDK integration for video calling, user management, and authentication features.

## Features

### ✅ Completed Features

1. **Authentication & Login Screen**
   - Email and password validation
   - Mock authentication with test credentials
   - Beautiful UI with Google Fonts and custom styling
   - Test credentials provided on login screen

2. **User List Screen**
   - REST API integration with ReqRes API
   - Offline caching with SharedPreferences
   - Pull-to-refresh functionality
   - Infinite scroll with pagination
   - User profile details and call initiation

3. **Video Call Screen**
   - AWS Chime SDK integration (placeholder implementation)
   - Camera and microphone controls
   - Screen sharing functionality (UI ready)
   - Permission handling for camera and microphone
   - Modern video calling interface

4. **Dashboard**
   - Clean navigation to different features
   - Modern card-based UI design
   - Logout functionality

5. **Splash Screen**
   - Professional branding with app logo
   - Loading animation
   - Automatic navigation based on authentication state

6. **App Configuration**
   - Required permissions for camera, microphone, and internet
   - Android and iOS platform configurations
   - Clean architecture with BLoC pattern
   - Dependency injection with GetIt

### 🔄 In Progress Features

- Enhanced authentication validation
- Screen share functionality implementation
- App signing and deployment configuration

## Technical Architecture

### Clean Architecture Pattern
- **Presentation Layer**: BLoC state management, UI screens, widgets
- **Domain Layer**: Entities, use cases, repository interfaces
- **Data Layer**: Data sources, repository implementations, models

### State Management
- **BLoC Pattern**: Used for state management throughout the app
- **GetIt**: Dependency injection container
- **Equatable**: Value equality for state classes

### Key Dependencies
- `flutter_bloc`: State management
- `flutter_aws_chime`: Video calling SDK
- `dio`: HTTP client for API calls
- `shared_preferences`: Local data caching
- `cached_network_image`: Image caching and loading
- `connectivity_plus`: Network connectivity monitoring
- `permission_handler`: Runtime permissions
- `go_router`: Navigation and routing

## Getting Started

### Prerequisites
- Flutter SDK (>=3.8.0)
- Dart SDK (>=3.8.0)
- Android Studio / VS Code
- Git
- Node.js and npm (for backend server)
- AWS Account (for video calling features)

### Quick Setup Guide

#### For Basic App (Without Video Calling)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd video_call_demo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

#### For Full Video Calling Setup

1. **Follow the AWS Chime SDK Setup section below**
2. **Set up the backend server with AWS credentials**
3. **Configure the Flutter app build.gradle**
4. **Run both backend and Flutter app**

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd video_call_demo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build Instructions

#### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

#### iOS
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## API Integration

### Authentication
The app uses mock authentication with the following test credentials:
- **Email**: `test@example.com`
- **Password**: `password123`

Or use ReqRes API credentials:
- **Email**: `eve.holt@reqres.in`
- **Password**: `cityslicka`

### User List API
- **Endpoint**: `https://jsonplaceholder.typicode.com/users`
- **Features**: Offline caching, pull-to-refresh, user details navigation
- **Cache Duration**: Persistent until app restart
- **Data**: 10 sample users with complete profile information

## AWS Chime SDK Setup

### Prerequisites
1. AWS Account with Chime SDK access
2. AWS IAM user with Chime permissions
3. Node.js and npm installed

### Step 1: AWS IAM User Setup

1. **Create IAM User**:
   - Go to AWS IAM Console
   - Create a new user with programmatic access
   - Attach the following policy or create a custom policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "chime:CreateMeeting",
                "chime:GetMeeting",
                "chime:DeleteMeeting",
                "chime:CreateAttendee",
                "chime:GetAttendee",
                "chime:DeleteAttendee"
            ],
            "Resource": "*"
        }
    ]
}
```

2. **Get AWS Credentials**:
   - Note down the Access Key ID and Secret Access Key
   - You'll need these for the backend server

### Step 2: Backend Server Setup

1. **Navigate to backend directory**:
   ```bash
   cd chime-backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Create .env file**:
   ```bash
   # Create .env file in chime-backend folder
   touch .env
   ```

4. **Add AWS credentials to .env**:
   ```env
   AWS_ACCESS_KEY_ID=your_access_key_id_here
   AWS_SECRET_ACCESS_KEY=your_secret_access_key_here
   AWS_REGION=us-east-1
   PORT=5000
   ```

5. **Start the backend server**:
   ```bash
   npm start
   ```

   The server will start on `http://localhost:5000`

### Step 3: Flutter App Configuration

1. **Update build.gradle** (IMPORTANT):
   - Open `android/app/build.gradle.kts`
   - Add namespace for flutter_aws_chime plugin:

```kotlin
android {
    namespace = "com.example.bloc_clean_architecture"
    // ... existing configuration ...
    
    // Add this for flutter_aws_chime plugin
    defaultConfig {
        // ... existing configuration ...
        
        // Required for AWS Chime SDK
        multiDexEnabled = true
    }
    
    // Add packaging options for AWS Chime
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
    }
}
```

2. **Update dependencies in pubspec.yaml**:
   ```yaml
   dependencies:
     flutter_aws_chime: ^1.0.0  # or latest version
   ```

3. **Run the Flutter app**:
   ```bash
   cd video_call_demo
   flutter pub get
   flutter run
   ```

### Step 4: Testing Video Calls

1. **Start the backend server** (if not already running):
   ```bash
   cd chime-backend
   npm start
   ```

2. **Run the Flutter app**:
   ```bash
   cd video_call_demo
   flutter run
   ```

3. **Test video calling**:
   - Navigate to Video Call section
   - Create or join a meeting
   - Test with multiple devices/emulators

### API Endpoints

The backend server provides the following endpoints:

- `POST /join` - Join or create a meeting
- `POST /leave` - Leave a meeting
- `POST /end` - End a meeting
- `POST /audio/toggle` - Toggle audio on/off
- `POST /video/toggle` - Toggle video on/off
- `GET /participants/:meetingId` - Get participant states
- `GET /health` - Health check
- `GET /meetings` - List active meetings

### Troubleshooting

1. **Backend server issues**:
   - Check AWS credentials are correct
   - Verify IAM permissions
   - Check server logs for errors

2. **Flutter app issues**:
   - Ensure backend server is running
   - Check network connectivity
   - Verify build.gradle configuration

3. **Video call issues**:
   - Grant camera and microphone permissions
   - Test on physical devices
   - Check AWS Chime SDK logs

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera for video calling</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for video calling</string>
```

## Project Structure

```
lib/
├── src/
│   ├── comman/                 # Common utilities, constants, themes
│   ├── data/                   # Data layer
│   │   ├── datasource/         # Remote and local data sources
│   │   ├── models/             # Data models with JSON serialization
│   │   └── repository/         # Repository implementations
│   ├── domain/                 # Domain layer
│   │   ├── entities/           # Business entities
│   │   ├── repositories/       # Repository interfaces
│   │   └── usecase/            # Use cases
│   ├── presentation/           # Presentation layer
│   │   ├── bloc/               # BLoC state management
│   │   ├── page/               # Screen widgets
│   │   ├── widget/             # Reusable widgets
│   │   └── cubit/              # Cubit state management
│   └── utilities/              # Utility functions and extensions
├── injection.dart              # Dependency injection setup
└── main.dart                   # App entry point
```

## Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
```

## Deployment

### Android Play Store
1. Generate signed APK/AAB
2. Configure app signing
3. Upload to Play Console
4. Complete store listing

### iOS App Store
1. Configure code signing
2. Archive the app
3. Upload to App Store Connect
4. Submit for review

## Troubleshooting

### Common Issues

1. **Build Runner Issues**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Permission Issues**
   - Ensure permissions are declared in manifest files
   - Test on physical devices for camera/microphone permissions

3. **AWS Chime SDK Issues**
   - Verify AWS credentials configuration
   - Check meeting creation backend
   - Ensure proper SDK initialization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review AWS Chime SDK documentation

### Current Status
- ✅ Backend server with AWS Chime SDK integration ready
- ✅ User list with JSONPlaceholder API integration
- ✅ Authentication flow with splash screen
- ✅ Clean architecture with BLoC pattern
- ✅ Offline caching and pull-to-refresh
- ✅ User details navigation
- 🔄 Video calling UI ready (needs AWS credentials setup)

### Known Limitations
- Video calling requires AWS credentials setup
- Authentication is mock-based (suitable for demonstration)
- Backend server needs to be running for video calls to work

## Acknowledgments

- Flutter team for the excellent framework
- AWS Chime SDK team for video calling capabilities
- BLoC library for state management
- All open-source contributors