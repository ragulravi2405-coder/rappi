import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        chat: (context) => const ChatScreen(),
        profile: (context) => const ProfileScreen(),
        settings: (context) => const SettingsScreen(),
        about: (context) => const AboutScreen(),
      };
}
