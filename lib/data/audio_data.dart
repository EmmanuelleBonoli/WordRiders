class AudioData {
  // Chemin de base pour les assets audios (le package audioplayers cherche "assets/" par défaut si on n'utilise pas AssetSource correctement, mais techniquement, AssetSource se base sur pubspec "assets/"). En général on met les sons dans assets/audio/
  // Donc ces strings seront le chemin relatif depuis `assets/`
  
  // -- Musiques --
  static const String musicBackground = 'sounds/music_bg.mp3';
  static const String musicGame = 'sounds/music_game.mp3';

  // -- Effets Sonores (SFX) --
  // UI & General
  static const String sfxButtonPress = 'sounds/sfx_button.mp3';
  static const String sfxCoin = 'sounds/sfx_coin.mp3';
  
  // Gameplay
  static const String sfxLetterClick = 'sounds/sfx_letter.mp3';
  static const String sfxWordValid = 'sounds/sfx_word_valid.mp3';
  static const String sfxWordInvalid = 'sounds/sfx_word_invalid.mp3';
  static const String sfxWin = 'sounds/sfx_win.mp3';
  static const String sfxLose = 'sounds/sfx_lose.mp3';
  static const String sfxLevelUp = 'sounds/sfx_level_up.mp3';
  
  // Cette liste rassemble tous les chemins pour le pré-chargement en mémoire
  static const List<String> allAudio = [
    musicBackground,
    musicGame,
    sfxButtonPress,
    sfxCoin,
    sfxLetterClick,
    sfxWordValid,
    sfxWordInvalid,
    sfxWin,
    sfxLose,
    sfxLevelUp,
  ];
}
