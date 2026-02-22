enum GoalType { daily, career }

enum GoalCategory {
  levelsWon,
  wordsFound,
  lettersUsed,
  streakDays,
  coinsEarned,
  adsWatched,
  wordsLength6,
  wordsLength7,
  wordsLength8Plus,
}

class Goal {
  final String id;
  final GoalType type;
  final GoalCategory category;
  final String titleKey;
  final String descriptionKey;
  final int target;
  final int reward;
  
  int current;
  bool isClaimed;

  Goal({
    required this.id,
    required this.type,
    required this.category,
    required this.titleKey,
    this.descriptionKey = '',
    required this.target,
    required this.reward,
    this.current = 0,
    this.isClaimed = false,
  });

  bool get isCompleted => current >= target;
  double get progress => (current / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'category': category.index,
    'titleKey': titleKey,
    'descriptionKey': descriptionKey,
    'target': target,
    'reward': reward,
    'current': current,
    'isClaimed': isClaimed,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'] as String,
    type: GoalType.values[json['type'] as int],
    category: GoalCategory.values[json['category'] as int],
    titleKey: json['titleKey'] as String,
    descriptionKey: json['descriptionKey']?.toString() ?? '',
    target: json['target'] as int,
    reward: json['reward'] as int,
    current: (json['current'] as num?)?.toInt() ?? 0,
    isClaimed: json['isClaimed'] as bool? ?? false,
  );
}
