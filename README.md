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

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter-bloc-clean-architecture-boilerplate
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
- **Endpoint**: `https://reqres.in/api/users`
- **Features**: Pagination, offline caching, pull-to-refresh
- **Cache Duration**: 24 hours

## AWS Chime SDK Setup

### Prerequisites
1. AWS Account with Chime SDK access
2. Configure AWS credentials
3. Set up meeting creation backend

### Configuration Steps

1. **Add AWS credentials** (for production):
   ```dart
   // In your backend service
   final meetingResponse = await createMeeting();
   ```

2. **Initialize Chime SDK**:
   ```dart
   // In video call screen
   await _initializeChimeSDK();
   ```

3. **Join meeting**:
   ```dart
   await _joinMeeting(meetingId, attendeeId);
   ```

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

## Roadmap

### Upcoming Features
- [ ] Real AWS Chime SDK integration
- [ ] Push notifications for incoming calls
- [ ] External camera support
- [ ] CI/CD pipeline setup
- [ ] Enhanced error handling
- [ ] Unit and integration tests
- [ ] Performance optimization

### Known Limitations
- Video calling is currently a placeholder implementation
- Screen sharing UI is ready but functionality needs AWS Chime integration
- Authentication is mock-based (suitable for demonstration)

## Acknowledgments

- Flutter team for the excellent framework
- AWS Chime SDK team for video calling capabilities
- BLoC library for state management
- All open-source contributors