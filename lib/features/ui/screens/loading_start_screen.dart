import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:word_riders/data/audio_data.dart';
import 'package:word_riders/features/gameplay/services/audio_service.dart';

import '../widgets/intro_loading/loading_messages_widget.dart';

class LoadingStartScreen extends StatefulWidget {
  const LoadingStartScreen({super.key});

  @override
  State<LoadingStartScreen> createState() => _LoadingStartScreenState();
}

class _LoadingStartScreenState extends State<LoadingStartScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Préchargement technique des sons
    final initFuture = AudioService().preloadAll().then((_) {
        // Lancement immédiat de la musique dès le préchargement terminé
        AudioService().playMusic(AudioData.musicBackground);
    }).catchError((e) {
        debugPrint("Erreur de chargement audio: $e");
    });
    
    // 2. Temporisation minimale visuelle (4 secondes)
    final minDelayFuture = Future.delayed(const Duration(seconds: 4));

    // 3. Attendre que le préchargement ET la temporisation soient terminés avant d'aller au menu
    await Future.wait([initFuture, minDelayFuture]);
    
    if (mounted) context.go('/menu');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/loading_bg2.jpg', 
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          
          Positioned.fill(
             child: Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.center,
                   colors: [
                     Colors.white.withValues(alpha: 0.4),
                     Colors.transparent,
                   ],
                 ),
               ),
             ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  
                  Image.asset(
                    'assets/images/logo_title_v3.png',
                    height: 180, 
                    fit: BoxFit.contain,
                  ),
                  

                  const Spacer(), 

                  CircularProgressIndicator(
                    color: theme.colorScheme.secondary,
                    strokeWidth: 5,
                  ),
                  const SizedBox(height: 50), 
                ],
              ),
            ),
          ),

          const LoadingMessagesWidget(),
        ],
      ),
    );
  }
}
