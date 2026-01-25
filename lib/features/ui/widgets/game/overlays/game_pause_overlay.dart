import 'dart:ui';
import 'package:flutter/material.dart';


class GamePauseOverlay extends StatelessWidget {
  const GamePauseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Flou fort pour bien cacher
        child: Container(
          color: Colors.white.withValues(alpha: 0.2), // Légère teinte pour unifier
          // Rien d'autre ! L'utilisateur est concentré sur la modale (Paramètres ou Quitter) qui est par-dessus.
        ),
      ),
    );
  }
}
