import 'package:word_train/features/gameplay/models/goal.dart';

class PlayerProfile {
  // Core
  int stage;
  int coins;
  int lives;
  DateTime lastLifeRegen;
  
  // Settings
  bool musicEnabled;
  bool sfxEnabled;
  bool tutorialCompleted;

  // Goals
  List<Goal> dailyGoals;
  List<Goal> careerGoals;
  DateTime? lastDailyReset;

  // Stats / Tracking
  List<String> usedWords;
  String? activeWord;
  List<String> campaignWords;
  
  // Tracking
  int lastAdStage;
  DateTime? unlimitedLivesUntil;
  
  // Localization
  String? locale;

  PlayerProfile({
    this.stage = 1,
    this.coins = 0,
    this.lives = 5,
    DateTime? lastLifeRegen,
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.tutorialCompleted = false,
    List<Goal>? dailyGoals,
    List<Goal>? careerGoals,
    this.lastDailyReset,
    List<String>? usedWords,
    this.activeWord,
    List<String>? campaignWords,
    this.lastAdStage = 0,
    this.unlimitedLivesUntil,
    this.locale,
  }) : 
    lastLifeRegen = lastLifeRegen ?? DateTime.now(),
    dailyGoals = dailyGoals ?? [],
    careerGoals = careerGoals ?? [],
    usedWords = usedWords ?? [],
    campaignWords = campaignWords ?? [];

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      stage: json['stage'] as int? ?? 1,
      coins: json['coins'] as int? ?? 0,
      lives: json['lives'] as int? ?? 5,
      lastLifeRegen: json['lastLifeRegen'] == null
          ? null
          : DateTime.parse(json['lastLifeRegen'] as String),
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      sfxEnabled: json['sfxEnabled'] as bool? ?? true,
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
      dailyGoals: (json['dailyGoals'] as List<dynamic>?)
          ?.map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      careerGoals: (json['careerGoals'] as List<dynamic>?)
          ?.map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastDailyReset: json['lastDailyReset'] == null
          ? null
          : DateTime.parse(json['lastDailyReset'] as String),
      usedWords: (json['usedWords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      activeWord: json['activeWord'] as String?,
      campaignWords: (json['campaignWords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastAdStage: json['lastAdStage'] as int? ?? 0,
       unlimitedLivesUntil: json['unlimitedLivesUntil'] == null
          ? null
          : DateTime.parse(json['unlimitedLivesUntil'] as String),
      locale: json['locale'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stage': stage,
        'coins': coins,
        'lives': lives,
        'lastLifeRegen': lastLifeRegen.toIso8601String(),
        'musicEnabled': musicEnabled,
        'sfxEnabled': sfxEnabled,
        'tutorialCompleted': tutorialCompleted,
        'dailyGoals': dailyGoals.map((e) => e.toJson()).toList(),
        'careerGoals': careerGoals.map((e) => e.toJson()).toList(),
        'lastDailyReset': lastDailyReset?.toIso8601String(),
        'usedWords': usedWords,
        'activeWord': activeWord,
        'campaignWords': campaignWords,
        'lastAdStage': lastAdStage,
        'unlimitedLivesUntil': unlimitedLivesUntil?.toIso8601String(),
        'locale': locale,
      };

  factory PlayerProfile.initial() => PlayerProfile();
}
