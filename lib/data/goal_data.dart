

import 'package:word_riders/features/gameplay/models/goal.dart';

// --- DEFINITIONS DES OBJECTIFS ---

// Objectifs Quotidiens par défaut
List<Goal> getDailyGoals() => [
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

// Objectifs de Carrière
List<Goal> getCareerGoals() => [
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
