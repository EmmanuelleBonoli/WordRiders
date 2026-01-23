import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/loading_messages_widget.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class LoadingStartScreen extends StatefulWidget {
  const LoadingStartScreen({super.key});

  @override
  State<LoadingStartScreen> createState() => _LoadingStartScreenState();
}

class _LoadingStartScreenState extends State<LoadingStartScreen> {
  @override
  void initState() {
    super.initState();

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
              'assets/images/background/menu_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          
          // Dégradé de superposition
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

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
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
                    color: AppTheme.green,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 60),

                CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                  strokeWidth: 5,
                ),
              ],
            ),
          ),

          const LoadingMessagesWidget(),
        ],
      ),
    );
  }
}
