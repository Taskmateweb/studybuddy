# 📚 StudyBuddy - Your Personal Study Companion

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" />
</div>

<p align="center">
  <strong>A modern, beautiful study management app built with Flutter to help students stay organized and motivated.</strong>
</p>

---

## ✨ Features

### 🔐 Authentication
- **User Registration** - Create your account with email and password
- **Secure Login** - Firebase Authentication integration
- **Password Recovery** - Reset password functionality
- **Beautiful Landing Page** - Animated welcome screen with gradient design

### 📝 Task Management
- **Create Tasks** - Add study tasks with title, description, due date, category, and priority
- **Task Categories** - Organize tasks by Study, Assignment, Project, Exam, Reading, Practice, and more
- **Priority Levels** - Set task priority (Low, Medium, High) with color-coded indicators
- **Task Completion** - Mark tasks as complete with celebration animations
- **Smart Organization** - Automatic separation of active and completed tasks
- **Real-time Updates** - Instant synchronization across devices

### 🎯 Dashboard
- **Study Statistics** - Track study hours, completed tasks, and focus scores
- **Today's Tasks** - Quick view of tasks due today
- **Study Streak** - 7-day streak visualization to stay motivated
- **Quick Actions** - Fast access to Focus Mode, Add Task, YouTube, and Routine
- **Completed Today Section** - See all tasks completed in the last 24 hours

### 🎨 Modern UI/UX
- **Material 3 Design** - Beautiful, modern interface following latest design guidelines
- **Purple Gradient Theme** - Eye-catching gradient color scheme
- **Smooth Animations** - Celebration confetti when completing tasks
- **Visual Feedback** - Green backgrounds and checkmarks for completed tasks
- **Responsive Design** - Works perfectly on different screen sizes
- **Dark Mode Ready** - Theme-aware components

### 🌟 Extra Features
- **Balance Your Life** - Encourage extra-curricular activities (Sports, Music, Art, Reading)
- **Prayer Reminder** - Dedicated prayer card with mosque icon
- **Focus Mode** *(Coming Soon)* - Pomodoro timer for focused study sessions
- **Daily Reminders** *(Coming Soon)* - Notifications for upcoming tasks
- **YouTube Integration** *(Coming Soon)* - Search educational content directly

---

## 📱 Screenshots

*(Add your app screenshots here)*

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Firebase account
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Taskmateweb/studybuddy.git
   cd studybuddy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable **Authentication** (Email/Password)
   - Enable **Cloud Firestore**
   - Download `google-services.json` (Android) and place it in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`

4. **Configure Firestore Security Rules**
   
   Deploy the following rules to your Firestore:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       match /tasks/{taskId} {
         allow read: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
         allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
         allow update, delete: if request.auth != null && 
                                request.auth.uid == resource.data.userId;
       }
     }
   }
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏗️ Project Structure

```
studybuddy/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   ├── task_model.dart       # Task data model
│   │   └── user_model.dart       # User data model
│   ├── screens/
│   │   ├── landing_page.dart     # Welcome screen
│   │   ├── login_screen.dart     # Login page
│   │   ├── register_screen.dart  # Registration page
│   │   ├── home_screen.dart      # Main dashboard
│   │   ├── add_task_screen.dart  # Create new task
│   │   └── task_detail_sheet.dart # Task details modal
│   ├── services/
│   │   ├── firebase_service.dart # Firebase configuration
│   │   └── task_service.dart     # Task CRUD operations
│   ├── widgets/
│   │   └── celebration_overlay.dart # Confetti animation
│   └── utils/
├── android/                       # Android specific files
├── ios/                          # iOS specific files
├── assets/                       # Images and assets
├── test/                         # Unit tests
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

---

## 📦 Dependencies

### Core
- `flutter` - Flutter framework
- `firebase_core: ^3.15.2` - Firebase initialization
- `firebase_auth: ^5.7.0` - Authentication
- `cloud_firestore: ^5.6.12` - Database

### State Management
- `provider: ^6.0.5` - State management

### UI/UX
- `google_fonts: ^6.2.0` - Custom fonts
- `flutter_native_splash: ^2.4.0` - Splash screen
- `fl_chart: ^0.68.0` - Charts and graphs

### Utilities
- `intl: ^0.18.0` - Date formatting
- `uuid: ^3.0.6` - Unique ID generation
- `shared_preferences: ^2.3.2` - Local storage
- `hive: ^2.2.3` - Local database
- `flutter_local_notifications: ^17.1.2` - Notifications

---

## 🎨 Design System

### Color Palette
```dart
Primary Gradient:
- Purple: #667EEA
- Pink: #764BA2
- Light Pink: #F093FB
- Blue: #4FACFE

Accent Colors:
- Green (Complete): #4CAF50
- Orange (Medium Priority): #FF9800
- Red (High Priority): #F44336
- Cyan (Low Priority): #00BCD4
```

### Typography
- **Font Family**: Google Fonts (Poppins/Inter)
- **Heading**: Bold, 20-24px
- **Body**: Regular, 14-16px
- **Caption**: Medium, 11-12px

---

## 🔥 Firebase Structure

### Collections

#### `users` Collection
```javascript
{
  "userId": "string",
  "email": "string",
  "displayName": "string",
  "createdAt": "timestamp"
}
```

#### `tasks` Collection
```javascript
{
  "id": "string",
  "title": "string",
  "description": "string",
  "dueDate": "timestamp",
  "isCompleted": "boolean",
  "completedAt": "timestamp",
  "userId": "string",
  "createdAt": "timestamp",
  "category": "string",
  "priority": "number (1-3)"
}
```

---

## 🧪 Testing

Run tests with:
```bash
flutter test
```

---

## 🚀 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 TODO / Roadmap

- [ ] Implement Focus Mode with Pomodoro timer
- [ ] Add daily reminder notifications
- [ ] YouTube integration for educational content search
- [ ] Create daily study routine scheduler
- [ ] Add study analytics and insights
- [ ] Implement prayer time notifications
- [ ] Add task editing functionality
- [ ] Implement task search and filter
- [ ] Add dark mode toggle
- [ ] Create onboarding tutorial
- [ ] Add profile customization
- [ ] Implement data export/import
- [ ] Add widgets for home screen

---

## 🐛 Known Issues

- None at the moment! 🎉

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Rakibul Islam**
- GitHub: [@rakibul414](https://github.com/rakibul414)
- Organization: [Taskmateweb](https://github.com/Taskmateweb)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for design inspiration
- All contributors and testers

---

## 📞 Support

If you like this project, please give it a ⭐️ on GitHub!

For issues and questions, please use the [Issues](https://github.com/Taskmateweb/studybuddy/issues) page.

---

<div align="center">
  Made with ❤️ and Flutter
</div>
