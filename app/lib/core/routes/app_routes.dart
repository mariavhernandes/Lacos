import 'package:flutter/material.dart';
import '../../main.dart';

class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
    };
  }
}