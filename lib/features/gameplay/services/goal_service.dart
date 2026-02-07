import 'package:flutter/foundation.dart';
import 'package:word_train/features/gameplay/models/goal.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';

class GoalService extends ChangeNotifier {
  static final GoalService _instance = GoalService._internal();
  factory GoalService() => _instance;
  GoalService._internal();

  List<Goal> _dailyGoals = [];
  List<Goal> _careerGoals = [];

  List<Goal> get dailyGoals => List.unmodifiable(_dailyGoals);
  List<Goal> get careerGoals => List.unmodifiable(_careerGoals);

  Future<void> init() async {
    final profile = await PlayerPreferences.getProfile();
    
    // Vérifier si vide
    if (profile.dailyGoals.isEmpty) {
        _generateDailyGoals();
        profile.dailyGoals = _dailyGoals;
        await PlayerPreferences.saveProfile(profile);
    } else {
        _dailyGoals = profile.dailyGoals;
    }

    if (profile.careerGoals.isEmpty) {
        _initCareerGoals(); // Générer les défauts
        // Simplification : si la liste est vide, on initialise.
        profile.careerGoals = _careerGoals;
        await PlayerPreferences.saveProfile(profile);
    } else {
        _careerGoals = profile.careerGoals;
    }

    // Vérification du reset quotidien
    await _checkDailyReset();
    notifyListeners();
  }

  // --- Gestion du Reset ---
  Future<void> _checkDailyReset() async {
    final profile = await PlayerPreferences.getProfile();
    final lastResetDate = profile.lastDailyReset;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool shouldReset = false;
    if (lastResetDate == null) {
      shouldReset = true;
    } else {
      final lastDay = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);
      if (lastDay.isBefore(today)) {
        shouldReset = true;
      }
    }

    if (shouldReset) {
      debugPrint("GoalService: Performing Daily Reset");
      _generateDailyGoals();
      profile.dailyGoals = _dailyGoals;
      profile.lastDailyReset = now;
      await PlayerPreferences.saveProfile(profile);
    }
  }

  // Générer les objectifs quotidiens standards
  void _generateDailyGoals() {
    _dailyGoals = [
      Goal(
        id: 'daily_win_3',
        type: GoalType.daily,
        category: GoalCategory.levelsWon,
        titleKey: 'campaign.goals.daily.win_3levels',
        target: 3,
        reward: 100,
      ),
      Goal(
        id: 'daily_words_30',
        type: GoalType.daily,
        category: GoalCategory.wordsFound,
        titleKey: 'campaign.goals.daily.words_30',
        target: 30,
        reward: 50,
      ),
      Goal(
        id: 'daily_ad_1',
        type: GoalType.daily,
        category: GoalCategory.adsWatched,
        titleKey: 'campaign.goals.daily.watch_ad',
        target: 1,
        reward: 30,
      ),
    ];
  }

  void _initCareerGoals() {
    _careerGoals = [
      Goal(
        id: 'career_level_10',
        type: GoalType.career,
        category: GoalCategory.levelsWon,
        titleKey: 'campaign.goals.career.reach_lvl10',
        descriptionKey: 'campaign.goals.career.reach_lvl10_desc',
        target: 10,
        reward: 200,
      ),
      Goal(
        id: 'career_words_100',
        type: GoalType.career,
        category: GoalCategory.wordsFound,
        titleKey: 'campaign.goals.career.words_100',
        descriptionKey: 'campaign.goals.career.words_100_desc',
        target: 100,
        reward: 300,
      ),
    ];
  }

  // --- Mise à jour de la progression ---
  Future<void> updateProgress(GoalCategory category, int amount) async {
    bool updated = false;

    // Mise à jour Quotidienne
    for (var goal in _dailyGoals) {
      if (goal.category == category && !goal.isCompleted) {
        goal.current += amount;
        if (goal.current > goal.target) goal.current = goal.target;
        updated = true;
      }
    }

    // Mise à jour Carrière
    for (var goal in _careerGoals) {
      if (goal.category == category && !goal.isCompleted) {
        goal.current += amount;
        if (goal.current > goal.target) goal.current = goal.target;
        updated = true;
      }
    }

    if (updated) {
        // Synchronisation avec le profil
        final profile = await PlayerPreferences.getProfile();
        profile.dailyGoals = _dailyGoals;
        profile.careerGoals = _careerGoals;
        await PlayerPreferences.saveProfile(profile);
        notifyListeners();
    }
  }

  Future<void> incrementLevelsWon(int count) async {
    await updateProgress(GoalCategory.levelsWon, count);
  }

  Future<void> incrementWordsFound(int count) async {
    await updateProgress(GoalCategory.wordsFound, count);
  }
  Future<void> incrementAdWatch() async {
    await updateProgress(GoalCategory.adsWatched, 1);
  }

  // --- Récupération des récompenses ---
  Future<bool> claim(String goalId) async {
    final profile = await PlayerPreferences.getProfile();
    _dailyGoals = profile.dailyGoals;
    _careerGoals = profile.careerGoals;

    Goal? goal;
    // Vérification quotidien
    try {
        goal = _dailyGoals.firstWhere((g) => g.id == goalId);
    } catch (_) {}
    
    // Vérification carrière
    if (goal == null) {
        try {
            goal = _careerGoals.firstWhere((g) => g.id == goalId);
        } catch (_) {}
    }

    if (goal != null && goal.isCompleted && !goal.isClaimed) {
        goal.isClaimed = true;
        profile.coins += goal.reward;
        
         // L'ajout de pièces est géré lors de la sauvegarde du profil
        await PlayerPreferences.saveProfile(profile);
        notifyListeners();
        return true;
    }

    return false;
  }

  // --- Réinitialisation Totale ---
  Future<void> resetAll() async {
    // La réinitialisation des objectifs se fait généralement lors du reset de campagne.
    _generateDailyGoals();
    _initCareerGoals();
    
    final profile = await PlayerPreferences.getProfile();
    profile.dailyGoals = _dailyGoals;
    profile.careerGoals = _careerGoals;
    profile.lastDailyReset = null;
    
    await PlayerPreferences.saveProfile(profile);
  }
}
