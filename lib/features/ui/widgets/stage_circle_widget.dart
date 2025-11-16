import 'package:flutter/material.dart';

class StageCircle extends StatelessWidget {
  final int number;
  final bool unlocked;

  const StageCircle({required this.number, required this.unlocked, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: unlocked ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text('$number', style: const TextStyle(color: Colors.white)),
    );
  }
}
