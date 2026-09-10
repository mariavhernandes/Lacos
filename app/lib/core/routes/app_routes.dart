import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/elderly_home_page.dart';
import '../../features/home/presentation/pages/family_home_page.dart';
import '../../features/login/presentation/pages/forgot_password_page.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/signup/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/public_profile_page.dart';

// ============================================================
// PERFIL DO FAMILIAR E EDIÇÃO
// ============================================================
import '../../features/profile/presentation/pages/family/family_profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile/edit_about_me_page.dart';
// import '../../features/profile/presentation/pages/edit_profile/edit_appearance_page.dart';
import '../../features/profile/presentation/pages/edit_profile/edit_basic_data_page.dart';
import '../../features/profile/presentation/pages/edit_profile/edit_interests_page.dart';

// ============================================================
// LOCAIS E ATIVIDADES
// ============================================================
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/discovery/presentation/screens/detail_screen.dart';
import '../../features/discovery/domain/models/place_activity.dart';

// ============================================================
// CHAT
// ============================================================
import '../../features/chat/screens/chat_list_screen.dart';

class AppRoutes {
  // ============================================================
  // ROTAS
  // ============================================================
  static const String home = '/';
  static const String discovery = '/discovery';
  static const String detail = '/detail';
  static const String login = '/login';
  static const String signup = SignupPage.routeName;
  static const String recoverPassword = '/recover-password';
  static const String splashScreen = '/splash';
  static const String elderlyHome = '/elderly-home';
  static const String familyHome = '/family-home';
  static const String profile = '/profile';
  static const String publicProfile = '/public-profile';
  static const String familyProfile = '/family-profile';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String chat = '/chat';

  // ============================================================
  // EDITAR PERFIL DO IDOSO
  // ============================================================
  static const String editAboutMe = '/edit-about-me';
  static const String editAppearance = '/edit-appearance';
  static const String editBasicData = '/edit-basic-data';
  static const String editInterests = '/edit-interests';

  // ============================================================
  // ROTAS DO APP
  // ============================================================
  static Map<String, WidgetBuilder> get routes {
    return {
      // ----------------------------------------------------------
      // LOGIN
      // ----------------------------------------------------------
      home: (context) => const LoginPage(),
      login: (context) => const LoginPage(),
      signup: (context) => const SignupPage(),
      recoverPassword: (context) => const ForgotPasswordPage(),

      // ----------------------------------------------------------
      // SPLASH
      // ----------------------------------------------------------
      splashScreen: (context) => const SplashScreen(),

      // ----------------------------------------------------------
      // HOME
      // ----------------------------------------------------------
      elderlyHome: (context) => const ElderlyHomePage(),
      familyHome: (context) => const FamilyHomePage(),

      // ----------------------------------------------------------
      // PERFIL
      // ----------------------------------------------------------
      profile: (context) => const ProfilePage(),
      publicProfile: (context) {
        final arguments =
            ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

        final uid = arguments?['uid'] as String? ?? '';

        return PublicProfilePage(uid: uid);
      },
      familyProfile: (context) => const FamilyProfilePage(),

      // ----------------------------------------------------------
      // NOTIFICAÇÕES
      // ----------------------------------------------------------
      notifications: (context) => const NotificationsPage(),

      // ----------------------------------------------------------
      // AJUDA
      // ----------------------------------------------------------
      help: (context) => const HelpPage(),

      // ----------------------------------------------------------
      // EDITAR SOBRE VOCÊ
      // ----------------------------------------------------------
      editAboutMe: (context) {
        final arguments =
            ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

        final uid = arguments?['uid'] as String? ?? '';
        final initialBio = arguments?['initialBio'] as String? ?? '';

        return EditAboutMePage(
          uid: uid,
          initialBio: initialBio,
        );
      },

      // ----------------------------------------------------------
      // EDITAR APARÊNCIA
      // ----------------------------------------------------------
      // editAppearance: (context) {
      //   return const EditAppearancePage();
      // },

      // ----------------------------------------------------------
      // EDITAR DADOS BÁSICOS
      // ----------------------------------------------------------
      editBasicData: (context) {
        final arguments =
            ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

        final uid = arguments?['uid'] as String? ?? '';

        final initialData =
            arguments?['initialData']
                as Map<String, dynamic>? ?? {};

        return EditBasicDataPage(
          uid: uid,
          initialData: initialData,
        );
      },

      // ----------------------------------------------------------
      // EDITAR INTERESSES
      // ----------------------------------------------------------
      editInterests: (context) {
        final arguments =
            ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

        final uid = arguments?['uid'] as String? ?? '';

        final currentInterests =
            (arguments?['currentInterests'] as List<dynamic>?)
                    ?.map((item) => item.toString())
                    .toList() ??
                [];

        return EditInterestsPage(
          uid: uid,
          currentInterests: currentInterests,
        );
      },

      // ----------------------------------------------------------
      // LOCAIS
      // ----------------------------------------------------------
      discovery: (context) => const DiscoveryScreen(),

      // ----------------------------------------------------------
      // DETALHES DO LOCAL/ATIVIDADE
      // ----------------------------------------------------------
      detail: (context) {
        final place =
            ModalRoute.of(context)?.settings.arguments as PlaceActivity;

        return DetailScreen(
          place: place,
        );
      },

      // ----------------------------------------------------------
      // CHAT
      // ----------------------------------------------------------
      chat: (context) => const ChatListScreen(),
    };
  }
}
