import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_riders/features/gameplay/services/goal_service.dart';
import 'package:word_riders/features/gameplay/models/goal.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PlayerPreferences.resetCampaign(); // Force un profil vide
    
    // Simule une initialisation propre
    final service = GoalService();
    await service.init();
    await service.resetAll(); // S'assure de repartir de zéro
  });

  group('GoalService Tests', () {
    test('init crée bien les objectifs (Quotidiens et Carrière) s\'ils sont vides', () async {
      final service = GoalService();
      
      expect(service.dailyGoals.isNotEmpty, isTrue);
      expect(service.careerGoals.isNotEmpty, isTrue);
    });

    test('updateProgress fait avancer correctement l\'objectif sans dépasser la cible', () async {
      final service = GoalService();
      
      // On prend un objectif lié aux niveaux gagnés existant dans les listes
      final careerGoal = service.careerGoals.firstWhere((g) => g.category == GoalCategory.levelsWon);
      final target = careerGoal.target;
      expect(careerGoal.current, equals(0));

      // On simule la victoire d'un niveau
      await service.incrementLevelsWon(1);
      
      // La progression devrait être à 1
      final updatedCareerGoal = service.careerGoals.firstWhere((g) => g.id == careerGoal.id);
      expect(updatedCareerGoal.current, equals(1));
      
      // On dépasse volontairement la cible totale (100 victoires)
      await service.updateProgress(GoalCategory.levelsWon, 999);
      
      // Vérifie que ça a cappé au maximum (target) et que c'est marqué complet
      final finishedGoal = service.careerGoals.firstWhere((g) => g.id == careerGoal.id);
      expect(finishedGoal.current, equals(target));
      expect(finishedGoal.isCompleted, isTrue);
    });

    test('claim accorde la récompense si l\'objectif est terminé', () async {
      final service = GoalService();
      
      // Initialise les pièces à 0 explicitement
      await PlayerPreferences.setCoins(0);

      // Trouve un objectif facile et on le complète d'un coup
      final targetGoal = service.dailyGoals.firstWhere((g) => g.category == GoalCategory.wordsFound);
      await service.incrementWordsFound(targetGoal.target);
      
      // S'assure que c'est complet mais pas réclamé
      final completedGoal = service.dailyGoals.firstWhere((g) => g.id == targetGoal.id);
      expect(completedGoal.isCompleted, isTrue);
      expect(completedGoal.isClaimed, isFalse);

      // On réclame !
      final success = await service.claim(completedGoal.id);
      
      expect(success, isTrue);
      
      // L'objectif doit être marqué comme réclamé
      final claimedGoal = service.dailyGoals.firstWhere((g) => g.id == completedGoal.id);
      expect(claimedGoal.isClaimed, isTrue);
      
      // Les pièces doivent avoir été créditées dans PlayerPreferences
      final coins = await PlayerPreferences.getCoins();
      expect(coins, equals(completedGoal.reward));

      // Réclamer une deuxième fois doit échouer
      final retrySuccess = await service.claim(completedGoal.id);
      expect(retrySuccess, isFalse);
    });
  });
}
