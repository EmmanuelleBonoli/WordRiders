import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';

import 'package:word_riders/features/gameplay/models/goal.dart';
import 'package:word_riders/features/gameplay/services/goal_service.dart';
import 'package:word_riders/features/gameplay/services/animation_service.dart';
import 'package:word_riders/features/ui/screens/main_scaffold.dart';
import 'package:word_riders/features/ui/widgets/careerGoals/daily_goal_card.dart';
import 'package:word_riders/features/ui/widgets/careerGoals/career_goal_tile.dart';

class TrophiesScreen extends StatefulWidget {
  const TrophiesScreen({super.key});

  @override
  State<TrophiesScreen> createState() => _TrophiesScreenState();
}

class _TrophiesScreenState extends State<TrophiesScreen> {
  @override
  void initState() {
    super.initState();
    GoalService().addListener(_refresh);
  }

  @override
  void dispose() {
    GoalService().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- SECTION 1 : SUCCÈS QUOTIDIENS ---
          _buildSectionHeader(context.tr('campaign.goals.headers.daily')),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: GoalService().dailyGoals.length,
              separatorBuilder: (ctx, index) => const SizedBox(width: 16),
              itemBuilder: (ctx, index) {
                final goal = GoalService().dailyGoals[index];
                return DailyGoalCard(
                  goal: goal,
                  onClaim: (context) => _handleClaim(context, goal),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // --- SECTION 2 : PROGRESSION DE CARRIÈRE ---
          _buildSectionHeader(context.tr('campaign.goals.headers.career')),
          const SizedBox(height: 12),
          
          Container(
             decoration: BoxDecoration(
              color: AppTheme.tileFace.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.brown, width: 3),

              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withValues(alpha: 0.3),
                   blurRadius: 10,
                   offset: const Offset(0, 6)
                 )
              ]
            ),
            child: Column(
              children: [
                ...GoalService().careerGoals.asMap().entries.map((entry) {
                   final index = entry.key;
                   final goal = entry.value;
                   final last = index == GoalService().careerGoals.length - 1;
                   
                   return Column(
                     children: [
                       CareerGoalTile(
                         goal: goal, 
                         onClaim: () => _handleClaim(context, goal),
                       ),
                       if (!last) _buildDivider(),
                     ],
                   );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.bookmark, color: AppTheme.orangeBurnt, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Round',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.coinRimTop, 
             shadows: [
              Shadow(color: AppTheme.darkBrown, blurRadius: 2, offset: Offset(1, 1)),
              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: AppTheme.brown.withValues(alpha: 0.2), height: 1),
    );
  }

  Future<void> _handleClaim(BuildContext buttonContext, Goal goal) async {
    if (goal.isClaimed) return;

    final success = await GoalService().claim(goal.id);
    if (!success) return;
    
    // Vérifier que l'écran est toujours monté
    if (!mounted) return;
    if (!buttonContext.mounted) return;

    // Logique d'animation  
    final RenderBox? buttonBox = buttonContext.findRenderObject() as RenderBox?;
    final mainScaffoldState = context.findAncestorStateOfType<MainScaffoldState>();
    final RenderBox? indicatorBox = mainScaffoldState?.coinIndicatorContext?.findRenderObject() as RenderBox?;

    if (buttonBox != null && indicatorBox != null) {
      final startPos = buttonBox.localToGlobal(buttonBox.size.center(Offset.zero));
      final endPos = indicatorBox.localToGlobal(indicatorBox.size.center(Offset.zero));

      AnimationService().showCoinAnimation(
        context: context,
        startPosition: startPos,
        endPosition: endPos,
        amount: 8,
        onComplete: () async {
            if (mounted) {
               setState(() {}); // Reconstruire pour afficher l'état "Récupéré"
               mainScaffoldState?.reloadIndicators();
            }
        },
      );
    } else {
        // Solution de repli sans animation
        if (mounted) {
             setState(() {});
             mainScaffoldState?.reloadIndicators();
        }
    }
  }
}
