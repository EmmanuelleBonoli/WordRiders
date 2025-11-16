import 'package:flutter/material.dart';
import '../../gameplay/services/player_preferences.dart';
import '../widgets/stage_circle_widget.dart';

class CampaignProgressScreen extends StatefulWidget {
  const CampaignProgressScreen({super.key});

  @override
  State<CampaignProgressScreen> createState() => _CampaignProgressScreenState();
}

class _CampaignProgressScreenState extends State<CampaignProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _stageAnimation;

  int _currentStage = 1;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadStageProgress();
  }

  Future<void> _loadStageProgress() async {
    _currentStage = await PlayerProgress.getCurrentStage();
    final startingStage = (_currentStage > 10)
        ? _currentStage - 10
        : _currentStage;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );

    _stageAnimation = IntTween(begin: startingStage, end: _currentStage)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // appBar: AppBar(leading: BackButton()),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/background/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BackButton(),
              AnimatedBuilder(
                animation: _stageAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 30,
                    children: _buildStageCircles(_stageAnimation.value),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStageCircles(int displayedStage) {
    return List.generate(10, (index) {
      final stageNumber = displayedStage - 4 + index;

      if (stageNumber < 1) {
        return const SizedBox(width: 40);
      }

      final unlocked = stageNumber <= _currentStage;

      return StageCircle(number: stageNumber, unlocked: unlocked);
    });
  }
}
