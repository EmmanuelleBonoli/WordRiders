import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/campaign/coin_indicator.dart';
import 'package:word_train/features/ui/widgets/campaign/life_indicator.dart';
import 'package:word_train/features/ui/widgets/campaign/no_ads_button.dart';
import 'package:word_train/features/ui/widgets/navigation/app_back_button.dart';
import 'package:word_train/features/ui/widgets/navigation/settings_button.dart';
import 'package:word_train/features/ui/widgets/navigation/campaign_bottom_nav_bar.dart';
import 'package:word_train/features/ui/widgets/graphics/leaf_background.dart';

class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  final GlobalKey<LifeIndicatorState> _lifeIndicatorKey = GlobalKey<LifeIndicatorState>();
  final GlobalKey<CoinIndicatorState> _coinIndicatorKey = GlobalKey<CoinIndicatorState>();
  
  int get currentLives => _lifeIndicatorKey.currentState?.currentLives ?? 5;
  BuildContext? get coinIndicatorContext => _coinIndicatorKey.currentContext;
  BuildContext? get lifeIndicatorContext => _lifeIndicatorKey.currentContext;

  void reloadIndicators() {
    _lifeIndicatorKey.currentState?.reload();
    _coinIndicatorKey.currentState?.reload();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index, BuildContext context) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Widget _buildBackground(int index, BuildContext context) {
    if (index == 1) {
       // = Campagne
       return Image.asset(
         'assets/images/background/game_bg.jpg',
         fit: BoxFit.cover,
         alignment: Alignment.center,
       );
    }

    // Store & Trophées
    return LeafBackground(
      backgroundColor: AppTheme.tileFace,
      leafColor: AppTheme.green.withValues(alpha: 0.15),
      leafCount: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = widget.navigationShell.currentIndex;
    
    return Scaffold(
      body: Stack(
        children: [
            Positioned.fill(
              child: _buildBackground(selectedIndex, context),
            ),
           SafeArea(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (selectedIndex == 2)
                              CoinIndicator(key: _coinIndicatorKey)
                            else if (selectedIndex == 1) 
                              AppBackButton(onPressed: () => context.go('/menu')) 
                            else 
                              const SizedBox(width: 64),
                            
                            Image.asset(
                             'assets/images/logo_title.png',
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                            const SettingsButton(),
                          ],
                        ),
                        if (selectedIndex == 0) ...[
                             const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CoinIndicator(key: _coinIndicatorKey),
                              LifeIndicator(key: _lifeIndicatorKey),
                            ],
                          ),
                        ] else if (selectedIndex == 1) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CoinIndicator(key: _coinIndicatorKey),
                              NoAdsButton(
                                onPurchased: () {
                                  _coinIndicatorKey.currentState?.reload();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              LifeIndicator(key: _lifeIndicatorKey),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: widget.navigationShell,
                  ),
                  CampaignBottomNavBar(
                    selectedIndex: selectedIndex,
                    onTap: (index) => _onItemTapped(index, context),
                  ),
               ],
             ),
           ),
        ],
      ),
    );
  }
}
