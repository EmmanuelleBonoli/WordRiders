import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/gameplay/models/goal.dart';
import 'package:easy_localization/easy_localization.dart';

class DailyGoalCard extends StatelessWidget {
  final Goal goal;
  final Function(BuildContext)? onClaim;

  const DailyGoalCard({
    super.key,
    required this.goal,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
     final bool completed = goal.isClaimed;
     final bool canClaim = !completed && goal.isCompleted;
     final double progress = goal.progress;
     
     // Détermine l'icône en fonction de la catégorie
     IconData icon;
     switch (goal.category) {
       case GoalCategory.levelsWon: icon = Icons.stars; break;
       case GoalCategory.wordsFound: icon = Icons.menu_book; break;
       case GoalCategory.adsWatched: icon = Icons.movie_filter; break;
       default: icon = Icons.emoji_events;
     }

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: completed 
             ? [AppTheme.coinRimTop, AppTheme.coinRimBottom] 
             : [AppTheme.tileFace, AppTheme.tileFace],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed ? AppTheme.coinBorderDark : (canClaim ? AppTheme.green : AppTheme.coinRimBottom),
          width: canClaim ? 3 : 2
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            completed ? Icons.check_circle : icon,
            size: 32,
            color: completed ? AppTheme.darkBrown : AppTheme.brown,
          ),
          Text(
            context.tr(goal.titleKey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Round',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: completed ? AppTheme.darkBrown : AppTheme.textDark,
            ),
          ),
          if (completed)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
               decoration: BoxDecoration(
                 color: AppTheme.darkBrown,
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Text(context.tr('campaign.goals.common.claimed'), style: const TextStyle(color: AppTheme.coinFaceTop, fontSize: 10, fontWeight: FontWeight.bold)),
             )
          else if (canClaim)
             Builder(
               builder: (btnContext) {
                 return GestureDetector(
                   onTap: () => onClaim?.call(btnContext),
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: AppTheme.green,
                       borderRadius: BorderRadius.circular(12),
                       boxShadow: const [
                         BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)
                       ]
                     ),
                     child: Text(context.tr('campaign.goals.common.claim'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                   ),
                 );
               }
             )
          else
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.brown.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.orangeBurnt),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/indicators/coin.png', width: 14, height: 14),
                    const SizedBox(width: 4),
                    Text(
                      "+${goal.reward}",
                        style: const TextStyle(
                        fontFamily: 'Round',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
