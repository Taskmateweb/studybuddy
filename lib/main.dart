import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/routine_screen.dart';
import 'screens/add_routine_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/extra_curricular_screen.dart';
import 'screens/youtube_screen.dart';
import 'screens/balance_your_life_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'services/task_notification_service.dart';
import 'services/prayer_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize task notification service
  final notificationService = TaskNotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  
  // Initialize prayer notification service
  final prayerNotificationService = PrayerNotificationService();
  await prayerNotificationService.initialize();
  await prayerNotificationService.requestPermissions();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/add-task': (context) => const AddTaskScreen(),
        '/routine': (context) => const RoutineScreen(),
        '/add-routine': (context) => const AddRoutineScreen(),
        '/focus': (context) => const FocusScreen(),
        '/extra-curricular': (context) => const ExtraCurricularScreen(),
        '/youtube': (context) => const YouTubeScreen(),
        '/balance-your-life': (context) => const BalanceYourLifeScreen(),
        '/notification-settings': (context) => const NotificationSettingsScreen(),
      },
    );
  }
}

// AuthGate widget to check if user is already logged in
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, go to home
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        
        // If user is not logged in, show landing page
        return const LandingPage();
      },
    );
  }
}
