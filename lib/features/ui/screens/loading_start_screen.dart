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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "WORD TRAIN",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),

          const LoadingMessagesWidget(),
        ],
      ),
    );
  }
}
