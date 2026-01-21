import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF88D498);
  static const Color secondaryBlue = Color(0xFF53B8BB);
  static const Color accentOrange = Color(0xFFFFA07A); // Light Salmon/Orange
  static const Color creamBackground = Color(0xFFF6FBF4);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF424242);
  static const Color softRed = Color(0xFFFF8FAB);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: creamBackground,
    primaryColor: primaryGreen,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryBlue,
      surface: surfaceWhite,
      error: softRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onError: Colors.white,
    ),
    
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      displayLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: textDark,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 4,
      shadowColor: primaryGreen.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}
