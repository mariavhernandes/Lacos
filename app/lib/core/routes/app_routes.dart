import 'package:flutter/material.dart';

import '../../main.dart';
import '../../features/chat/screens/chat_list_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      chat: (context) => const ChatListScreen(),
    };
  }
}
