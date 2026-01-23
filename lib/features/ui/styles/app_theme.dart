import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette de couleurs du Design "Papier/Nature"
  static const Color cream = Color(0xFFFFF3E0);      // Fond, Boutons clairs
  static const Color brown = Color(0xFF8D6E63);      // Couleur principale, Bordures, Icônes
  static const Color darkBrown = Color(0xFF5D4037);  // Titres, Textes importants
  static const Color green = Color(0xFF558B2F);      // Validation, Succès, Accents nature
  static const Color red = Color(0xFFD32F2F);        // Erreur, Reset
  static const Color orange = Color(0xFFFFA07A);     // Accents secondaires
  
  static const Color textDark = Color(0xFF424242);   // Texte courant

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: cream,
    primaryColor: brown,
    fontFamily: 'Round', // Police par défaut pour tout l'app
    
    colorScheme: const ColorScheme.light(
      primary: brown,
      secondary: green,
      tertiary: orange,
      surface: cream,
      error: red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkBrown,
      onError: Colors.white,
    ),
    
    // Configuration des textes par défaut
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      displayLarge: const TextStyle(
        fontFamily: 'Round',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Round',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
      titleLarge: const TextStyle(
        fontFamily: 'Round',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: brown,
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
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Round',
          fontSize: 18, 
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    iconTheme: const IconThemeData(
      color: brown,
      size: 28,
    ),
    
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.9),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: brown, width: 2),
      ),
    ),
  );
}
