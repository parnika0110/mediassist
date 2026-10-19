import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        const Color(0xFF0A0F1E),

    cardColor:
        const Color(0xFF141B2D),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00D4FF),
      secondary: Color(0xFF3B82F6),
    ),

    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:
          Color(0xFF0A0F1E),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,

      fillColor:
          const Color(0xFF141B2D),

      labelStyle: const TextStyle(
        color: Colors.white70,
      ),

      hintStyle: const TextStyle(
        color: Colors.white38,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.white24,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF00D4FF),
          width: 2,
        ),
      ),
    ),
  );
}