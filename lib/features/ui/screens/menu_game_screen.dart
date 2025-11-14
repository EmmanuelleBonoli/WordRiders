import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widgets/button_widget.dart';

class MenuGameScreen extends StatelessWidget {
  const MenuGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- fond dégradé ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF202020)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // --- contenu principal ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- logo ou titre du jeu ---
                Column(
                  children: const [
                    Text(
                      'WORD TRAIN',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'by Major Manu Productions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- boutons du menu ---
                MenuButton(
                  text: tr('menu.campaign'),
                  onPressed: () => context.go('/campaign'),
                ),
                MenuButton(
                  text: tr('menu.training'),
                  onPressed: () => context.go('/game'),
                ),
                MenuButton(
                  text: tr('menu.settings'),
                  onPressed: () => context.go('/settings'),
                ),
                MenuButton(
                  text: tr('menu.quit'),
                  onPressed: () => _confirmQuit(context),
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
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          tr("menu.confirmQuitTitle"),
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          tr("menu.confirmQuitMessage"),
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              tr("menu.confirmQuitCancel"),
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // ferme la popup
              SystemNavigator.pop(); // quitte l'application
            },
            child: Text(
              tr("menu.quit"),
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
