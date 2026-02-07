import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/gameplay/models/goal.dart';
import 'package:easy_localization/easy_localization.dart';

class CareerGoalTile extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onClaim;

  const CareerGoalTile({
    super.key,
    required this.goal,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = goal.isCompleted;
    final double progress = goal.progress;
    
    IconData icon;
     switch (goal.category) {
       case GoalCategory.levelsWon: icon = Icons.school; break;
       case GoalCategory.wordsFound: icon = Icons.emoji_events; break;
       case GoalCategory.streakDays: icon = Icons.whatshot; break;
       default: icon = Icons.star;
     }

    // utilise descriptionKey si disponible, sinon réutilise le titre ou vide
    final String description = goal.descriptionKey.isNotEmpty 
        ? tr(goal.descriptionKey) 
        : '${tr('campaign.goals.career.target_label')} ${goal.target}'; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.coinFaceTop.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.coinRimBottom, width: 2),
            ),
            child: Icon(
              icon,
              color: AppTheme.coinRimBottom,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Info & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(goal.titleKey),
                  style: TextStyle(
                    fontFamily: 'Round',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Round',
                    fontSize: 12,
                    color: AppTheme.brown.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(AppTheme.green),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${goal.current}/${goal.target}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
           if (goal.isClaimed)
            const Icon(Icons.check_circle, color: AppTheme.green, size: 28)
           else if (completed && !goal.isClaimed)
            // Bouton Claim pour la carrière aussi!
             GestureDetector(
                onTap: onClaim,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.orangeBurnt,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]
                  ),
                  child: Text(tr('campaign.goals.common.claim'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
             )
        ],
      ),
    );
  }
}
