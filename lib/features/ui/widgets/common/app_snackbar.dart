import 'package:flutter/material.dart';
import 'package:word_riders/data/audio_data.dart';
import 'package:word_riders/features/gameplay/services/audio_service.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    Color bgColor = isError ? AppTheme.brown : AppTheme.green;

    AudioService().playSfx(isError ? AudioData.sfxLose : AudioData.sfxWin);

    // Annule les snackbars en cours pour afficher la nouvelle immédiatement
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Round',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
