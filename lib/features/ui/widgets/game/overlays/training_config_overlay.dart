import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class TrainingConfigOverlay extends StatelessWidget {
  final Function(int) onSelectLength;
  final VoidCallback onBack;

  const TrainingConfigOverlay({
    super.key,
    required this.onSelectLength,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/game_bg.jpg',
            fit: BoxFit.cover,
          ),
        ),

        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.4)),
        ),
        
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: MediaQuery.of(context).size.height - 48,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            tr('menu.training'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.brown,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Round',
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: BouncingScaleButton(
                            onTap: onBack,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Nombre de lettres :",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildOption(context, 6, "Facile"),
                  const SizedBox(height: 12),
                  _buildOption(context, 7, "Moyen"),
                  const SizedBox(height: 12),
                  _buildOption(context, 8, "Difficile"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, int count, String label) {
    return BouncingScaleButton(
      onTap: () => onSelectLength(count),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.goldButtonFace,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.goldButtonShadow,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              "$count Lettres",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.brown,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
