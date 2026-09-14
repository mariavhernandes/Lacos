import 'package:flutter/material.dart';

import '../../features/discovery/presentation/screens/discovery_screen.dart';

class AppRoutes {
static const String home = '/';
static const String discovery = '/discovery';

static Map<String, WidgetBuilder> get routes {
return {
home: (context) => const DiscoveryScreen(),
discovery: (context) => const DiscoveryScreen(),
};
}
}
