import 'package:flutter/material.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laços',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.home,
      routes: AppPages.routes,
    );
  }
}