import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/gameplay/services/word_service.dart';
import 'package:word_train/features/gameplay/services/goal_service.dart';

enum GameStatus { loading, waitingForConfig, playing, paused, won, lost }

class GameController extends ChangeNotifier {
  final bool isCampaign;
  final String locale;

  GameStatus _status = GameStatus.loading;
  String _targetWord = "";
  List<String> _shuffledLetters = [];
  String _currentInput = "";
  int? _trainingLength;

  Timer? _gameTimer;
  final Set<String> _sessionWords = {}; // Mots trouvés dans la partie en cours

  double _rabbitProgress = 0.0;
  double _foxProgress = 0.0;
  // Vitesse du renard : % du parcours par seconde. 
  double _foxSpeed = 0.01;

  GameStatus get status => _status;
  String get targetWord => _targetWord; 
  int get currentStage => _currentStageId;
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
      
      // 1. On s'assure que le dictionnaire est chargé
      await _wordService.loadDictionary(locale);

      if (!isCampaign && _trainingLength == null) {
        _status = GameStatus.waitingForConfig;
        notifyListeners();
        return;
      }

      if (isCampaign) {
         // En mode campagne, on récupère un mot du niveau (juste pour avoir les lettres)
         int currentStage = await PlayerPreferences.getCurrentStage();
         _currentStageId = currentStage;
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

         // Ajustement de la difficulté (Vitesse du renard)
         if (currentStage % 5 == 0) {
           // Distance doublée = Temps doublé pour le joueur
           // Donc le jeu doit durer 2x plus longtemps de base -> Vitesse / 2
           _foxSpeed /= 2; 
         }
         if (currentStage % 10 == 0) {
           // Boss Level ! On accélère le renard
           _foxSpeed *= 1.3;
         }
      } else {
        // En mode Entraînement
        int len = _trainingLength ?? 6;
        _targetWord = await _wordService.getNextCampaignWord(locale, stage: 1, forceLength: len); 
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

  Future<void> startTraining(int length) async {
    _trainingLength = length;
    await _initializeGame();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    
    // ENTRAINEMENT : Pas de timer ni de renard
    if (!isCampaign) return;

    // Rafraichissement toutes les 100ms
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_status != GameStatus.playing) {
        // En pause on ne fait rien, mais on ne coupe pas le timer pour autant
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

    if (_currentInput.length < 20) { 
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

  int _currentStageId = 1;

  // Retourne true si le mot est valide et fait avancer le lapin
  bool validate() {
    if (_status != GameStatus.playing) return false;
    
    final word = _currentInput.toUpperCase();

    // 1. Longueur min du mot proposé
    if (word.length < 3) {
      showFeedback(tr('game.feedback_too_short'));
      clearInput();
      return false;
    }

    // 2. Mot déjà trouvé ?
    if (_sessionWords.contains(word)) {
      showFeedback(tr('game.feedback_already_used'));
      clearInput();
      return false;
    }

    // 3. Mot existe dans le dico ?
    if (_wordService.isValid(word)) {
      _sessionWords.add(word);
      GoalService().incrementWordsFound(1); // Fire and forget
      
      // Faire avancer le lapin
      // Formule de progression : plus le mot est long, plus on avance ?
      double advance = 0.15; // Un mot = 15% de la course
      if (word.length >= 6) advance = 0.25;

      // DIFFICULTÉ : Si stage fini par 5 ou 0, la distance est doublée
      // Doubler la distance revient à diviser la progression par 2
      if (isCampaign) {
         if (_currentStageId % 5 == 0) {
           advance /= 2.0;
         }
      } else {
         // Entrainement : distance plus longue (progression plus lente) si 7 ou 8 lettres
         if ((_trainingLength ?? 6) >= 7) {
             advance /= 2.0;
         }
      }

      _rabbitProgress += advance;

      if (_rabbitProgress >= 1.0) {
        _rabbitProgress = 1.0;
        _handleWin();
      }
      
      clearInput();
      return true;
    }
    
    // Mot invalide/inconnu
    showFeedback(tr('game.feedback_invalid'));
    clearInput();
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
      await GoalService().incrementLevelsWon(1);
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
