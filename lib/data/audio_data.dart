class AudioData {
  
  // -- Musique --
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
  
  static const List<String> allAudio = [
    musicGame,
    sfxButtonPress,
    sfxCoin,
    sfxLetterClick,
    sfxWordValid,
    sfxWordInvalid,
    sfxWin,
    sfxLose
  ];
}
