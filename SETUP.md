# Setup Guide for StudyBuddy

This guide will walk you through setting up the StudyBuddy project on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Flutter SDK** (3.0 or higher)
  - Download from: https://flutter.dev/docs/get-started/install
  - Verify installation: `flutter --version`
  
- **Dart SDK** (2.17 or higher)
  - Comes bundled with Flutter
  - Verify: `dart --version`

- **Git**
  - Download from: https://git-scm.com/downloads
  - Verify: `git --version`

### Development Environment (Choose one)
- **Android Studio** (Recommended)
  - Download from: https://developer.android.com/studio
  - Install Flutter and Dart plugins
  
- **VS Code**
  - Download from: https://code.visualstudio.com/
  - Install Flutter and Dart extensions

### Mobile Development Setup

#### For Android Development
- Android Studio
- Android SDK (API 21 or higher)
- Android Emulator or physical device

#### For iOS Development (macOS only)
- Xcode (latest version)
- CocoaPods: `sudo gem install cocoapods`
- iOS Simulator or physical device

---

## Step-by-Step Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Taskmateweb/studybuddy.git
cd studybuddy
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

### 3. Firebase Setup

#### 3.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "StudyBuddy"
4. Follow the setup wizard
5. Enable Google Analytics (optional)

#### 3.2 Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click "Get Started"
3. Enable **Email/Password** sign-in method
4. Click "Save"

#### 3.3 Enable Cloud Firestore
1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select your region
5. Click "Enable"

#### 3.4 Add Android App to Firebase
1. In Firebase Console, click on Android icon
2. Enter package name: `com.example.studybuddy`
   - Find this in `android/app/build.gradle` under `applicationId`
3. Enter app nickname (optional): "StudyBuddy Android"
4. Download `google-services.json`
5. Place file in `android/app/` directory

**File location should be:**
```
studybuddy/
└── android/
    └── app/
        └── google-services.json  ← Here
```

#### 3.5 Add iOS App to Firebase (macOS only)
1. In Firebase Console, click on iOS icon
2. Enter bundle ID: `com.example.studybuddy`
   - Find this in `ios/Runner/Info.plist`
3. Download `GoogleService-Info.plist`
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag `GoogleService-Info.plist` into Runner folder in Xcode
6. Ensure "Copy items if needed" is checked

#### 3.6 Deploy Firestore Security Rules
1. In Firebase Console, go to **Firestore Database**
2. Click on "Rules" tab
3. Replace existing rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Tasks collection - users can only access their own tasks
    match /tasks/{taskId} {
      // Allow reading if the task belongs to the user
      allow read: if request.auth != null && 
                  request.auth.uid == resource.data.userId;
      
      // Allow creating if the task belongs to the user
      allow create: if request.auth != null && 
                    request.auth.uid == request.resource.data.userId;
      
      // Allow updating/deleting if the task belongs to the user
      allow update, delete: if request.auth != null && 
                             request.auth.uid == resource.data.userId;
    }
  }
}
```

4. Click "Publish"

### 4. Verify Flutter Setup

```bash
flutter doctor
```

This command checks your environment and displays a report. Fix any issues shown.

### 5. Run the App

#### On Android Emulator
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

#### On Physical Device
1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

#### Hot Reload
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

---

## Common Issues and Solutions

### Issue 1: "google-services.json not found"
**Solution:**
- Ensure `google-services.json` is in `android/app/` directory
- Restart your IDE
- Run `flutter clean` and `flutter pub get`

### Issue 2: "Firebase initialization failed"
**Solution:**
- Verify Firebase configuration files are in correct locations
- Check package name matches in Firebase Console
- Ensure Firebase is initialized in `main.dart`

### Issue 3: "Build failed" on Android
**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue 4: CocoaPods error on iOS
**Solution:**
```bash
cd ios
pod install
cd ..
flutter run
```

### Issue 5: "Permission denied" on Firestore
**Solution:**
- Verify security rules are deployed
- Ensure user is authenticated
- Check userId matches in database

---

## Development Workflow

### Making Changes
1. Create a new branch: `git checkout -b feature/my-feature`
2. Make your changes
3. Test thoroughly
4. Format code: `flutter format .`
5. Commit: `git commit -m "Add my feature"`
6. Push: `git push origin feature/my-feature`

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Building for Release

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only)
```bash
flutter build ios --release
# Then open Xcode to archive and upload
```

---

## Project Structure

```
studybuddy/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/
│   ├── main.dart        # App entry point
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic
│   ├── widgets/         # Reusable widgets
│   └── utils/           # Helper functions
├── test/                # Unit and widget tests
├── pubspec.yaml         # Dependencies
└── README.md           # Documentation
```

---

## Useful Commands

```bash
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Clean build files
flutter clean

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Build APK
flutter build apk

# Check for outdated packages
flutter pub outdated
```

---

## Environment Variables (Optional)

For sensitive data, consider using environment variables:

1. Create `.env` file in root (add to .gitignore)
2. Install flutter_dotenv package
3. Load variables in main.dart

---

## Next Steps

1. ✅ Setup complete!
2. 📱 Run the app and test all features
3. 🎨 Customize UI/theme if needed
4. 🔧 Start developing new features
5. 📚 Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

---

## Support

If you encounter any issues:
1. Check this guide thoroughly
2. Search existing [GitHub Issues](https://github.com/Taskmateweb/studybuddy/issues)
3. Create a new issue with detailed information
4. Include error messages, screenshots, and system info

---

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)

---

Happy Coding! 🚀
