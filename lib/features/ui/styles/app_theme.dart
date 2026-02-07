import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===========================================================================
  // 1. PALETTE PRIMITIVE (Couleurs de base)
  // ===========================================================================
  
  // Marrons & Bois
  static const Color _brownDark = Color(0xFF3E2723);    // Chocolat (Emplacements, Texte sombre)
  static const Color _brownMedium = Color(0xFF5D4037);  // Marron foncé (Ombres, Texte des tuiles)
  static const Color _brownMain = Color(0xFF8D6E63);    // Bois moyen (Plateaux, Bordures)
  static const Color _headerWood = Color(0xFFCF9E64);   // Bois clair (En-tête)
  
  // Jaunes & Dorés
  static const Color _cream = Color(0xFFFFF8E1);        // Face de tuile
  static const Color _creamLight = Color(0xFFFFF3E0);   // Face de panneau
  static const Color _amberMain = Color(0xFFFFB300);    // Ombre de tuile
  static const Color _yellowGold = Color(0xFFFFCA28);   // Bouton Valider
  static const Color _yellowPale = Color(0xFFFFE082);   // Reflet Valider
  
  // Éléments UI Dorés (Boutons, Pièces)
  static const Color _goldFace = Color(0xFFFCE1AE);     // Face de bouton
  static const Color _goldShadow = Color(0xFFDCA750);   // Ombre de bouton
  static const Color _goldHighlight = Color(0xFFFFF5D6); // Reflet de bouton
  
  // Rouges & Oranges
  static const Color _redMain = Color(0xFFD32F2F);      // Erreur, Danger
  static const Color _redDark = Color(0xFFBF360C);      // Ombre profonde
  static const Color _redShadow = Color(0xFF870000);    // Ombre sombre
  static const Color _redSurface = Color(0xFFFFEBEE);   // Fond rouge clair
  static const Color _orangeBurnt = Color(0xFFD84315);  // Bouton Mélanger
  static const Color _orangeSalmon = Color(0xFFFFAB91); // Reflet Mélanger

  // Verts
  static const Color _greenMain = Color(0xFF2E7D32);    // Succès, No Ads Actif
  static const Color _greenLight = Color(0xFF81C784);   // Reflet Succès
  
  // Neutres
  static const Color _beigeMain = Color(0xFFD7CCC8);
  static const Color _beigeLight = Color(0xFFEFEBE9);
  static const Color _greyDark = Color(0xFF424242);
  static const Color _white = Colors.white;

  // Dégradés spécifiques Pièces/Premium
  static const Color _coinRimTop = Color(0xFFFDEBAB); 
  static const Color _coinRimBottom = Color(0xFFE6BD6D);
  static const Color _coinFaceTop = Color(0xFFF0C882);
  static const Color _coinFaceBottom = Color(0xFFE19736);

  // ===========================================================================
  // 2. TOKENS SÉMANTIQUES (Usage Fonctionnel)
  // ===========================================================================

  // Texte général
  static const Color textDark = _greyDark;
  static const Color white = _white;
  
  // Actions génériques
  static const Color brown = _brownMain;
  static const Color darkBrown = _brownDark;
  
  // Boutons d'action
  static const Color btnValidate = _yellowGold;
  static const Color btnValidateShadow = _redDark;
  static const Color btnValidateHighlight = _yellowPale;

  static const Color btnShuffle = _orangeBurnt;
  static const Color btnShuffleShadow = _redShadow;
  static const Color btnShuffleHighlight = _orangeSalmon;

  // Bouton Doré Standard (Nouveau Standard)
  static const Color goldButtonFace = _goldFace;
  static const Color goldButtonShadow = _goldShadow;
  static const Color goldButtonHighlight = _goldHighlight;

  // Bouton/Indicateur Vert Standard
  static const Color green = _greenMain; 
  static const Color success = _greenMain; 
  static const Color greenMain = _greenMain;
  static const Color greenLight = _greenLight;
  static const Color greenButtonShadow = _greenMain; 
  static const Color greenButtonHighlight = _greenLight;

  static const Color red = _redMain;
  static const Color orange = _orangeBurnt;
  static const Color orangeSalmon = _orangeSalmon;
  static const Color orangeBurnt = _orangeBurnt;
  static const Color surfaceLightRed = _redSurface;

  // Tuiles & Plateau
  static const Color tileFace = _cream;
  static const Color tileShadow = _amberMain;
  static const Color tileText = _brownMedium;
  static const Color woodBoard = _brownMain;
  static const Color woodSlot = _brownDark;
  static const Color headerWood = _headerWood;
  
  // Panneaux de niveau
  static const Color levelSignFace = _creamLight;
  static const Color levelSignBorder = _brownMain;

  // Highlights & Ombres spécifiques (Bois)
  static const Color woodBoardHighlight = Color(0xFFA1887F);
  static const Color woodBoardShadow = _brownMedium;

  // Neutres (Beige)
  static const Color neutralBeige = _beigeMain;
  static const Color neutralBeigeLight = _beigeLight;
  static const Color neutralBeigeShadow = _brownMain;

  // Pièces Premium / assets spécifiques
  static const Color coinBorderDark = Color(0xFF753D00);
  static const Color coinRimTop = _coinRimTop;
  static const Color coinRimBottom = _coinRimBottom;
  static const Color coinFaceTop = _coinFaceTop;
  static const Color coinFaceBottom = _coinFaceBottom;
  static const Color coinIconFill = _coinRimTop;
  static const Color coinIconOutline = _coinRimBottom;
  static const Color inputCartridgeFill = Color(0xFFD19B5B);

  // Fonts
  static String get fontFamily => GoogleFonts.fredoka().fontFamily!;


  // ===========================================================================
  // 3. THEME DATA
  // ===========================================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: tileFace,
    primaryColor: tileShadow,
    fontFamily: GoogleFonts.fredoka().fontFamily,
    
    colorScheme: const ColorScheme.light(
      primary: tileShadow,
      secondary: tileFace,
      tertiary: neutralBeige,
      surface: tileFace,
      error: red,
      onPrimary: darkBrown,
      onSecondary: darkBrown,
      onSurface: darkBrown,
      onError: Colors.white,
    ),
    
    textTheme: GoogleFonts.fredokaTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      displayLarge: TextStyle(
        fontFamily: GoogleFonts.fredoka().fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
      displayMedium: TextStyle(
        fontFamily: GoogleFonts.fredoka().fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
      titleLarge: TextStyle(
        fontFamily: GoogleFonts.fredoka().fontFamily,
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
        elevation: 4, 
        shadowColor: darkBrown.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), 
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: TextStyle(
          fontFamily: GoogleFonts.fredoka().fontFamily,
          fontSize: 18, 
          fontWeight: FontWeight.w900, 
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
