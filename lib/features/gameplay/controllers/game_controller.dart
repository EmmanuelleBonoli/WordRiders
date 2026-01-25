import 'dart:async';
import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/gameplay/services/word_service.dart';

enum GameStatus { loading, playing, paused, won, lost }

class GameController extends ChangeNotifier {
  final bool isCampaign;
  final String locale;

  GameStatus _status = GameStatus.loading;
  String _targetWord = "";
  List<String> _shuffledLetters = [];
  String _currentInput = "";

  Timer? _gameTimer;
  final Set<String> _sessionWords = {}; // Mots trouvés dans cette partie

  double _rabbitProgress = 0.0;
  double _foxProgress = 0.0;
  // Vitesse du renard : % du parcours par seconde. 
  // Ralenti pour être plus accessible (approx 100s maintenant)
  final double _foxSpeed = 0.01;

  GameStatus get status => _status;
  String get targetWord => _targetWord; // Sert de "Seed" pour les lettres
  List<String> get shuffledLetters => List.unmodifiable(_shuffledLetters);
  String get currentInput => _currentInput;
  bool get isLoading => _status == GameStatus.loading;
  bool get isPaused => _status == GameStatus.paused;
  
  double get rabbitProgress => _rabbitProgress;
  double get foxProgress => _foxProgress;

  String? _feedbackMessage;
  String? get feedbackMessage => _feedbackMessage;

  GameController({required this.isCampaign, required this.locale}) {
    _initializeGame();
  }
  
  final _wordService = WordService();

  Future<void> _initializeGame() async {
    _status = GameStatus.loading;
    notifyListeners();

    try {
      debugPrint("GameController: Loading dictionary & word for locale: $locale");
      
      // 1. On s'assure que le dictionnaire est chargé pour la validation
      await _wordService.loadDictionary(locale);

      if (isCampaign) {
         // En mode campagne, on récupère un mot du niveau (juste pour avoir les lettres)
         int currentStage = await PlayerPreferences.getCurrentStage();
         String? stageWord = await PlayerPreferences.getWordForStage(currentStage);
         
         if (stageWord != null && stageWord.isNotEmpty) {
           _targetWord = stageWord;
           debugPrint("GameController: Restored existing word for stage $currentStage: $_targetWord");
         } else {
           // Génération d'un nouveau mot adapté à la difficulté
           _targetWord = await _wordService.getNextCampaignWord(locale, stage: currentStage);
           // IMPORTANT : On sauvegarde ce mot pour ce stage pour qu'il ne change pas si on quitte/revient
           await PlayerPreferences.setWordForStage(currentStage, _targetWord);
           debugPrint("GameController: Generated and saved new word for stage $currentStage: $_targetWord");
         }
      } else {
        // En mode Entraînement : On n'a pas de "stage" formel, mais on peut simuler un niveau 1 (6 lettres)
        // ou permettre au joueur de choisir. Par défaut : Facile (6 lettres)
        // Pour l'entraînement on reste sur du 6 lettres pour l'instant
        _targetWord = await _wordService.getNextCampaignWord(locale, stage: 1); 
      }
      
      // Mélange des lettres
      List<String> chars = _targetWord.split('');
      chars.shuffle();
      _shuffledLetters = chars;

      // Reset état de la partie
      _rabbitProgress = 0.0;
      _foxProgress = 0.0;
      _currentInput = "";
      _sessionWords.clear();
      _status = GameStatus.playing;
      
      _startGameLoop();

    } catch (e) {
      debugPrint("GameController: ERROR initializing game: $e");
      _targetWord = "ERREUR";
      _shuffledLetters = ["E", "R", "R", "E", "U", "R"];
      _status = GameStatus.playing;
    }

    notifyListeners();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    
    // ENTRAINEMENT : Pas de timer, pas de renard, pas de stress !
    if (!isCampaign) return;

    // Rafraichissement toutes les 100ms
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_status != GameStatus.playing) {
        // En pause on ne fait rien, mais on ne coupe pas le timer pour autant 
        // (sauf si fin de partie, géré ailleurs)
        return;
      }

      // Avancée du renard (vitesse par seconde / 10 pour 100ms)
      _foxProgress += _foxSpeed / 10;
      
      if (_foxProgress >= 1.0) {
        _foxProgress = 1.0;
        _handleLoss();
      }
      
      notifyListeners();
    });
  }



  void onLetterTap(String letter) {
    if (_status != GameStatus.playing) return;

    if (_currentInput.length < _targetWord.length) { // Limite arbitraire ou 8 ?
      _currentInput += letter;
      notifyListeners();
    }
  }

  void onBackspace() {
    if (_status != GameStatus.playing) return;

    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      notifyListeners();
    }
  }

  void onShuffle() {
    if (_status != GameStatus.playing) return;
    
    _shuffledLetters.shuffle();
    notifyListeners();
  }

  /// Retourne true si le mot est valide et fait avancer le lapin
  bool validate() {
    if (_status != GameStatus.playing) return false;
    
    final word = _currentInput.toUpperCase();

    // 1. Longueur min
    if (word.length < 3) return false;

    // 2. Déjà trouvé ?
    if (_sessionWords.contains(word)) return false;

    // 3. Existe dans le dico ?
    if (_wordService.isValid(word)) {
      _sessionWords.add(word);
      
      // Faire avancer le lapin
      // Formule de progression : plus le mot est long, plus on avance ?
      // Pour l'instant : fixe ou boost
      double advance = 0.15; // Un mot = 15% de la course
      if (word.length >= 6) advance = 0.25;

      _rabbitProgress += advance;

      if (_rabbitProgress >= 1.0) {
        _rabbitProgress = 1.0;
        _handleWin();
      }
      
      clearInput();
      return true;
    }
    
    return false;
  }

  void clearInput() {
    _currentInput = "";
    notifyListeners();
  }

  Future<void> _handleWin() async {
    _status = GameStatus.won;
    _gameTimer?.cancel();

    if (isCampaign) {
      await PlayerPreferences.addCoins(60); 
      await PlayerPreferences.addUsedWord(_targetWord); 
      
      int currentStage = await PlayerPreferences.getCurrentStage();
      await PlayerPreferences.setCurrentStage(currentStage + 1);
    }
    notifyListeners();
  }

  // Permet de quitter proprement en comptabilisant la défaite si nécessaire
  Future<void> quitGame() async {
    _gameTimer?.cancel();
    // Si on quitte une partie en cours en mode campagne, c'est une défaite (donc perte de vie)
    if (isCampaign && (_status == GameStatus.playing || _status == GameStatus.paused)) {
      await PlayerPreferences.loseLife();
    }
    _status = GameStatus.lost; // On marque comme fini pour éviter des effets de bord
    notifyListeners();
  }

  // Consomme une vie pour un restart manuel (équivalent à un abandon)
  Future<bool> consumeLifeForRestart() async {
    return await PlayerPreferences.loseLife();
  }

  void restartGame() {
    _status = GameStatus.loading;
    notifyListeners();
    _initializeGame();
  }

  void pauseGame() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      notifyListeners();
    }
  }

  Timer? _feedbackTimer;

  void showFeedback(String message) {
    _feedbackTimer?.cancel();
    _feedbackMessage = message;
    notifyListeners();

    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      _feedbackMessage = null;
      notifyListeners();
    });
  }

  Future<void> _handleLoss() async {
    _status = GameStatus.lost;
    _gameTimer?.cancel();
    
    if (isCampaign) {
      await PlayerPreferences.loseLife();
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
