import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    
    // Durée de l'écran de chargement avant d'aller au menu
    Timer(const Duration(seconds: 4), () {
      if (mounted) context.go('/menu');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/loading_bg2.png', 
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
                    'assets/images/logo_title.png',
                    height: 180, 
                    fit: BoxFit.contain,
                  ),
                  

                  const Spacer(), 

                  CircularProgressIndicator(
                    color: theme.colorScheme.secondary,
                    strokeWidth: 5,
                  ),
                  const SizedBox(height: 120), 
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
