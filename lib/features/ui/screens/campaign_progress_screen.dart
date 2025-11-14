import 'package:flutter/material.dart';
import '../../gameplay/services/player_preferences.dart';

class CampaignProgressScreen extends StatefulWidget {
  const CampaignProgressScreen({super.key});

  @override
  State<CampaignProgressScreen> createState() =>
      _CampaignProgressAnimationScreenState();
}

class _CampaignProgressAnimationScreenState
    extends State<CampaignProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _stageAnimation;
  int _currentStage = 1;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initStage();
  }

  Future<void> _initStage() async {
    _currentStage = await PlayerProgress.getCurrentStage();

    int startStage = (_currentStage > 10) ? _currentStage - 10 : 1;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _stageAnimation = IntTween(
      begin: startStage,
      end: _currentStage,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    setState(() => _isLoaded = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progression')),
      body: Center(
        child: AnimatedBuilder(
          animation: _stageAnimation,
          builder: (context, child) {
            int displayedStage = _stageAnimation.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                // On affiche les 5 derniers stages animés
                int stageNumber = displayedStage - 4 + index;
                if (stageNumber < 1) return const SizedBox(width: 40);
                bool unlocked = stageNumber <= _currentStage;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: unlocked ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$stageNumber',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
