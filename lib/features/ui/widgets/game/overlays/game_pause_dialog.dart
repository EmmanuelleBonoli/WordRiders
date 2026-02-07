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
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // MAIN BOARD
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: AppTheme.coinBorderDark,
                    borderRadius: BorderRadius.circular(32),
                     boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.5)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
                      ),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                      decoration: BoxDecoration(
                        color: AppTheme.levelSignFace,
                        borderRadius: BorderRadius.circular(26.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Message Text
                          Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textDark, 
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Horizontal Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                               // Quitter
                              Expanded(
                                child: GameModalButton(
                                  label: tr('game.quit'),
                                  icon: Icons.close_rounded,
                                  color: AppTheme.red,
                                  textColor: Colors.white,
                                  iconColor: Colors.white,
                                  onPressed: widget.onQuit,
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Rejouer
                              Expanded(
                                child: GameModalButton(
                                  label: tr('game.replay'),
                                  icon: Icons.refresh_rounded,
                                  color: AppTheme.btnShuffle,
                                  textColor: Colors.white,
                                  iconColor: Colors.white,
                                  onPressed: widget.onRestart,
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Continuer
                              Expanded(
                                child: GameModalButton(
                                  label: tr('game.continue'),
                                  icon: Icons.play_arrow_rounded,
                                  color: AppTheme.greenMain,
                                  textColor: Colors.white,
                                  iconColor: Colors.white,
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

                // HEADER
                Positioned(
                  top: -24,
                  child: _buildHeaderRibbon(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildHeaderRibbon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: AppTheme.coinBorderDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, 
            offset: Offset(0, 4), 
            blurRadius: 4
          )
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14.5)),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
          ),
        ),
        padding: const EdgeInsets.all(3.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.levelSignFace, 
            borderRadius: BorderRadius.circular(11.5),
          ),
          child: Text(
            widget.title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.coinBorderDark,
              fontWeight: FontWeight.w900,
              fontFamily: 'Round',
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
