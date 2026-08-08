import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/elderly_home_page.dart';
import '../../features/home/presentation/pages/family_home_page.dart';
import '../../features/login/presentation/pages/forgot_password_page.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/signup/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/help/presentation/pages/help_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = SignupPage.routeName;
  static const String recoverPassword = '/recover-password';
  static const String splashScreen = '/splash';
  static const String elderlyHome = '/elderly-home';
  static const String familyHome = '/family-home';
  static const String notifications = '/notifications';
  static const String help = '/help';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const LoginPage(),
      login: (context) => const LoginPage(),
      signup: (context) => const SignupPage(),
      recoverPassword: (context) => const ForgotPasswordPage(),
      splashScreen: (context) => const SplashScreen(),
      elderlyHome: (context) => const ElderlyHomePage(),
      familyHome: (context) => const FamilyHomePage(),
      notifications: (context) => const NotificationsPage(),
      help: (context) => const HelpPage(),
    };
  }
}