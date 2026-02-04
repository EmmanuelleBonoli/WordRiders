import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/game/game_modal_button.dart';

class GamePauseDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const GamePauseDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  State<GamePauseDialog> createState() => _GamePauseDialogState();
}

class _GamePauseDialogState extends State<GamePauseDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -5), 
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.tileFace,
                        border: Border.all(color: AppTheme.brown.withValues(alpha: 0.3), width: 3),
                      ),
                      child: const Icon(
                        Icons.pause_rounded,
                        size: 36,
                        color: AppTheme.brown,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.brown,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    widget.message,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.3),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Boutons en ligne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       // Quitter
                      Expanded(
                        child: GameModalButton(
                          label: tr('game.quit'),
                          icon: Icons.close_rounded,
                          color: AppTheme.red,
                          onPressed: widget.onQuit,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Rejouer
                      Expanded(
                        child: GameModalButton(
                          label: tr('game.replay'),
                          icon: Icons.refresh_rounded,
                          color: AppTheme.orange,
                          onPressed: widget.onRestart,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Continuer
                      Expanded(
                        child: GameModalButton(
                          label: tr('game.continue'),
                          icon: Icons.play_arrow_rounded,
                          color: AppTheme.green,
                          onPressed: widget.onResume,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
