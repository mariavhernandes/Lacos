import 'package:flutter/material.dart';
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/discovery/presentation/screens/detail_screen.dart';
import '../../features/discovery/domain/models/place_activity.dart';

class AppRoutes {
  static const String home = '/';
  static const String discovery = '/discovery';
  static const String detail = '/detail';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const DiscoveryScreen(),
      discovery: (context) => const DiscoveryScreen(),
      detail: (context) {
        final place = ModalRoute.of(context)?.settings.arguments as PlaceActivity;
        return DetailScreen(place: place);
      },
    };
  }
}