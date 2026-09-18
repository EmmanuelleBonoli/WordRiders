import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/coin_indicator.dart';
import 'package:word_riders/features/ui/widgets/common/life_indicator.dart';
import 'package:word_riders/features/ui/widgets/campaign/no_ads_button.dart';
import 'package:word_riders/features/ui/widgets/common/navigation/app_back_button.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_button.dart';
import 'package:word_riders/features/ui/widgets/common/navigation/campaign_bottom_nav_bar.dart';
import 'package:word_riders/features/ui/widgets/common/leaf_background.dart';
import 'package:word_riders/features/ui/widgets/game/game_background.dart';
import 'package:word_riders/features/ui/widgets/game/race_track_geometry.dart';
import 'package:word_riders/features/ui/widgets/game/race_track_geometry_scope.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  final GlobalKey<LifeIndicatorState> _lifeIndicatorKey =
      GlobalKey<LifeIndicatorState>();
  final GlobalKey<CoinIndicatorState> _coinIndicatorKey =
      GlobalKey<CoinIndicatorState>();

  int get currentLives => _lifeIndicatorKey.currentState?.currentLives ?? 5;
  BuildContext? get coinIndicatorContext => _coinIndicatorKey.currentContext;
  BuildContext? get lifeIndicatorContext => _lifeIndicatorKey.currentContext;

  // --- Mesure de la zone de contenu (pour la géométrie de piste de campagne) ---
  // On mesure la région occupée par `navigationShell` afin de fournir à
  // CampaignProgressScreen une géométrie de piste alignée sur le fond plein
  // écran, sans qu'il ait à se localiser lui-même.
  final GlobalKey _contentKey = GlobalKey();
  double _contentTop = 0;
  double _contentHeight = 0;
  bool _contentMeasured = false;

  // --- Mesure du header (pour caler le haut du fond sur le milieu des
  // boutons premium retour/réglages, comme sur l'écran de jeu). ---
  final GlobalKey _headerKey = GlobalKey();
  double _headerMidY = 0;
  bool _headerMeasured = false;

  void _measureContent() {
    final RenderObject? obj = _contentKey.currentContext?.findRenderObject();
    if (obj is! RenderBox || !obj.hasSize) return;
    final double top = obj.localToGlobal(Offset.zero).dy;
    final double height = obj.size.height;
    if (!_contentMeasured ||
        (top - _contentTop).abs() > 0.5 ||
        (height - _contentHeight).abs() > 0.5) {
      setState(() {
        _contentTop = top;
        _contentHeight = height;
        _contentMeasured = true;
      });
    }
  }

  void _measureHeader() {
    final RenderObject? obj = _headerKey.currentContext?.findRenderObject();
    if (obj is! RenderBox || !obj.hasSize) return;
    final double midY = obj.localToGlobal(Offset.zero).dy + obj.size.height / 2;
    if (!_headerMeasured || (midY - _headerMidY).abs() > 0.5) {
      setState(() {
        _headerMidY = midY;
        _headerMeasured = true;
      });
    }
  }

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

  Widget _buildBackground(
    int index,
    double bottomReserved,
    double topReserved,
  ) {
    if (index == 1) {
      // = Campagne : fond de course 3 couches, statique (pas de défilement).
      // `up` remonte jusqu'au tout haut de l'écran (derrière le header) ;
      // la ride line/ligne de stage, elles, restent calées sur topReserved.
      return GameBackground(
        bottomReserved: bottomReserved,
        topReserved: topReserved,
        stretchUpToTop: true,
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

    // Re-mesure des repères de fond après la frame (no-op si inchangés).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureContent();
      _measureHeader();
    });

    final Size screenSize = MediaQuery.of(context).size;
    // Hauteur basse à ne pas recouvrir = barre de nav campagne + safe area.
    // Avant la 1ʳᵉ mesure : estimation (barre de nav = 80 + marge).
    final double bottomReserved = _contentMeasured
        ? (screenSize.height - _contentTop - _contentHeight).clamp(
            0.0,
            screenSize.height,
          )
        : 100.0;
    // Haut : milieu des boutons premium retour/réglages, comme sur l'écran de jeu.
    final double topReserved = _headerMeasured
        ? _headerMidY
        : MediaQuery.of(context).padding.top + 48;
    final RaceTrackGeometry campaignGeometry = raceTrackGeometry(
      screenSize,
      bottomReserved: bottomReserved,
      topReserved: topReserved,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildBackground(selectedIndex, bottomReserved, topReserved),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      KeyedSubtree(
                        key: _headerKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (selectedIndex == 1)
                              AppBackButton(
                                onPressed: () => context.go('/menu'),
                              )
                            else
                              const SizedBox(width: 64),

                            Image.asset(
                              'assets/images/logo_title_v3.png',
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                            const SettingsButton(),
                          ],
                        ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 18),
                                CoinIndicator(key: _coinIndicatorKey),
                                const SizedBox(height: 22),
                                LifeIndicator(key: _lifeIndicatorKey),
                              ],
                            ),
                            const Spacer(),
                            NoAdsButton(
                              onPurchased: () {
                                _coinIndicatorKey.currentState?.reload();
                              },
                            ),
                          ],
                        ),
                      ] else if (selectedIndex == 2) ...[
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [CoinIndicator(key: _coinIndicatorKey)],
                        ),
                      ],
                    ],
                  ),
                ),
                // KeyedSubtree : ancre de mesure de la zone de contenu.
                // RaceTrackGeometryScope : fournit la géométrie de piste alignée
                // sur le fond plein écran à CampaignProgressScreen.
                Expanded(
                  child: KeyedSubtree(
                    key: _contentKey,
                    child: RaceTrackGeometryScope(
                      geometry: campaignGeometry,
                      contentTop: _contentTop,
                      child: widget.navigationShell,
                    ),
                  ),
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
