import 'dart:async';
import 'package:flutter/material.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/bounded_content.dart';

class CampaignBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CampaignBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<CampaignBottomNavBar> createState() => _CampaignBottomNavBarState();
}

class _CampaignBottomNavBarState extends State<CampaignBottomNavBar> {
  int _unclaimedCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkGoals();
    // Vérifie périodiquement les mises à jour
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _checkGoals());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkGoals() async {
    final count = await PlayerPreferences.getUnclaimedGoalsCount();
    if (mounted && count != _unclaimedCount) {
      setState(() {
        _unclaimedCount = count;
      });
    }
  }

  static const List<IconData> _icons = [
    Icons.store,
    Icons.videogame_asset,
    Icons.emoji_events,
  ];

  static const double _pillWidth = 90.0;
  static const double _pillHeight = 90.0;
  static const double _iconSizeSelected = 60.0;
  static const double _iconSizeUnselected = 40.0;
  static const Duration _slideDuration = Duration(milliseconds: 450);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.tileFace,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBrown.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth > ContentWidth.standard.maxWidth
              ? ContentWidth.standard.maxWidth
              : constraints.maxWidth;
          final slotWidth = totalWidth / _icons.length;

          return Center(
            child: SizedBox(
              width: totalWidth,
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Pill de sélection : glisse d'un slot à l'autre
                  AnimatedPositioned(
                    duration: _slideDuration,
                    curve: Curves.easeOutCubic,
                    left:
                        widget.selectedIndex * slotWidth +
                        (slotWidth - _pillWidth) / 2,
                    bottom: 5,
                    width: _pillWidth,
                    height: _pillHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppTheme.coinRimTop, AppTheme.coinFaceBottom],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.coinBorderDark, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(
                      _icons.length,
                      (index) => _buildNavItem(index, _icons[index], slotWidth),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, double slotWidth) {
    final isSelected = index == widget.selectedIndex;
    final iconSize = isSelected ? _iconSizeSelected : _iconSizeUnselected;

    return SizedBox(
      width: slotWidth,
      height: 80,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SizedBox(
                height: _pillHeight,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: iconSize),
                        duration: _slideDuration,
                        curve: Curves.easeOutCubic,
                        builder: (context, size, _) => Icon(
                          icon,
                          size: size,
                          color: isSelected
                              ? AppTheme.darkBrown
                              : AppTheme.tileShadow,
                        ),
                      ),
                      if (index == 2 && _unclaimedCount > 0)
                        Positioned(
                          top: -10,
                          right: -15,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '$_unclaimedCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Round',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
