import 'package:flutter/material.dart';

class AppPages {
  AppPages._();

  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const Scaffold(
          body: Center(
            child: Text('Laços'),
          ),
        ),
  };
}