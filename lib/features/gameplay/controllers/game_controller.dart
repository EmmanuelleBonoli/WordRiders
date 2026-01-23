import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/gameplay/services/word_service.dart';

enum GameStatus { loading, playing, won }

class GameController extends ChangeNotifier {
  final bool isCampaign;
  final String locale;

  GameStatus _status = GameStatus.loading;
  String _targetWord = "";
  List<String> _shuffledLetters = [];
  String _currentInput = "";

  GameStatus get status => _status;
  String get targetWord => _targetWord;
  List<String> get shuffledLetters => List.unmodifiable(_shuffledLetters);
  String get currentInput => _currentInput;
  bool get isLoading => _status == GameStatus.loading;
  double get progress => _targetWord.isEmpty ? 0.0 : _currentInput.length / _targetWord.length;

  GameController({required this.isCampaign, required this.locale}) {
    _initializeGame();
  }
  
  final _wordService = WordService();

  Future<void> _initializeGame() async {
    _status = GameStatus.loading;
    notifyListeners();

    try {
      debugPrint("GameController: Loading word for locale: $locale");
      
      if (isCampaign) {
        // En mode Campagne : on priorise le mot déjà actif s'il existe (reprise de partie en cours)
        String? storedWord = await PlayerProgress.getActiveWord();
        if (storedWord != null && storedWord.isNotEmpty) {
           _targetWord = storedWord;
           debugPrint("GameController: Restored active word: $_targetWord");
        } else {
           // Sinon on récupère le mot prévu pour le stage actuel
           int currentStage = await PlayerProgress.getCurrentStage();
           String? stageWord = await PlayerProgress.getWordForStage(currentStage);
           
           if (stageWord != null) {
             _targetWord = stageWord;
             await PlayerProgress.setActiveWord(_targetWord);
             debugPrint("GameController: Set word for stage $currentStage: $_targetWord");
           } else {
             // Fin de campagne ou problème (plus de mots)
             // Fallback temporaire : on génère un mot
             _targetWord = await _wordService.getNextCampaignWord(locale);
             await PlayerProgress.setActiveWord(_targetWord);
             debugPrint("GameController: Fallback generated word (End of list?): $_targetWord");
           }
        }
      } else {
        // En mode Entraînement : on génère toujours un nouveau mot (pas de persistance)
        _targetWord = await _wordService.getNextCampaignWord(locale); 
        debugPrint("GameController: Generated new word (Training): $_targetWord");
      }
      
      // Mélange des lettres
      List<String> chars = _targetWord.split('');
      chars.shuffle();
      _shuffledLetters = chars;

      _status = GameStatus.playing;
    } catch (e, stack) {
      debugPrint("GameController: ERROR initializing game: $e");
      final shortStack = stack.toString().split('\n').take(3).join('\n');
      debugPrint("Stack (short): $shortStack");
      
      // Fallback en cas d'erreur critique
      _targetWord = "ERREUR";
      _shuffledLetters = ["E", "R", "R", "E", "U", "R"];
      _status = GameStatus.playing;
    }

    notifyListeners();
  }

  void onLetterTap(String letter) {
    if (_status != GameStatus.playing) return;

    if (_currentInput.length < _targetWord.length) {
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

  /// Retourne true si le mot est valide (gagné)
  bool validate() {
    if (_currentInput == _targetWord) {
      _handleWin();
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
    if (isCampaign) {
      await PlayerProgress.addUsedWord(_targetWord);
      await PlayerProgress.clearActiveWord(); // On nettoie le mot actif pour que le prochain stage en génère un nouveau
      int currentStage = await PlayerProgress.getCurrentStage();
      await PlayerProgress.setCurrentStage(currentStage + 1);
    }
    notifyListeners();
  }
}
