import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widgets/button_widget.dart';

class MenuGameScreen extends StatelessWidget {
  const MenuGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/menu_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter, // Focus on the bottom details (flowers, bike wheels)
            ),
          ),
          
          // Overlay gradient
          Positioned.fill(
             child: Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     Colors.white.withValues(alpha: 0.3),
                     Colors.transparent,
                     Colors.white.withValues(alpha: 0.5),
                   ],
                 ),
               ),
             ),
          ),

          SafeArea(
            child: Row(
              children: [
                // --- Partie Gauche : Titre ---
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          // Outline
                          Text(
                            'WORD\nTRAIN',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 64,
                              height: 0.9,
                              letterSpacing: 2,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Fill
                          Text(
                            'WORD\nTRAIN',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: theme.primaryColor,
                              fontSize: 64,
                              height: 0.9,
                              letterSpacing: 2,
                              shadows: [
                                 BoxShadow(
                                   color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                                   blurRadius: 8,
                                   offset: const Offset(0, 4),
                                 ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'by Major Manu Productions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF558B2F),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Partie Droite : Boutons ---
                Expanded(
                  flex: 4,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MenuButton(
                              text: tr('menu.campaign'),
                              onPressed: () => context.push('/campaign'),
                            ),
                            MenuButton(
                              text: tr('menu.training'),
                              onPressed: () => context.push('/game'),
                            ),
                            MenuButton(
                              text: tr('menu.settings'),
                              onPressed: () => context.push('/settings'),
                            ),
                            MenuButton(
                              text: tr('menu.quit'),
                              onPressed: () => _confirmQuit(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95), // Slight transparency
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          tr("menu.confirmQuitTitle"),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary, // Using theme primary
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          tr("menu.confirmQuitMessage"),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
             color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              tr("menu.confirmQuitCancel"),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); 
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(tr("menu.quit")),
          ),
        ],
      ),
    );
  }
}
