import 'package:flutter/material.dart';
import '../../main.dart';
import '../../features/signup/presentation/pages/signup_page.dart';

class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      SignupPage.routeName: (context) => const SignupPage(),
    };
  }
}