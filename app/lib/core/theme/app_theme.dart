import 'package:flutter/material.dart';

class AppTheme {
  // Cores do Laços
  static const Color primaryColor = Color(0xFF033B63);
  static const Color secondaryColor = Color(0xFF466A99);
  static const Color accentColor = Color(0xFF9ED1FF);

  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: backgroundColor,

      primaryColor: primaryColor,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
      ),

      fontFamily: 'Quicksand',

      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: secondaryColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: primaryColor,
        ),

        displayMedium: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: primaryColor,
        ),

        titleLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),

        bodyLarge: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 16,
          color: Colors.black87,
        ),

        bodyMedium: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 14,
          color: Colors.black87,
        ),

        labelLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}