import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const LandingPage(),
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
      },
    );
  }
}
