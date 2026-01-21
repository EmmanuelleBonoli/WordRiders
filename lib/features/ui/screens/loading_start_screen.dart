import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/loading_messages_widget.dart';

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
      // Background inherits from theme (cream)
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "WORD TRAIN",
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.primaryColor,
                    fontSize: 42,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 30),
                CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
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
