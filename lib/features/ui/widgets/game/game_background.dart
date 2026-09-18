import 'package:flutter/widgets.dart';

import 'race_track_geometry.dart';

/// Fond de course en 3 couches (`up` / `track` / `down`), partagé par l'écran
/// de jeu, l'écran de campagne et les overlays.
///
/// Les couches sont positionnées via [raceTrackGeometry] : la piste peinte
/// tombe donc exactement sur `rideLineY`, quel que soit le ratio de l'écran.
///
/// - `up` (arrière-plan lointain) et `down` (avant-plan) défilent
///   horizontalement quand [scrollOffset] varie, à des vitesses différentes
///   (effet de parallaxe). Chacune n'est étirée qu'en hauteur (le ratio
///   largeur/hauteur natif est conservé, pas de déformation) et juxtaposée en
///   autant de copies que nécessaire pour couvrir l'écran — les bords
///   gauche/droit des assets se raccordent pour un bouclage sans couture.
/// - `track` reste **fixe** : c'est une bande quasi unie qui sert de référence
///   stable pour la position des personnages. Elle est étirée verticalement
///   selon la géométrie (invisible sur un aplat).
///
/// [scrollOffset] à 0 (défaut) => fond entièrement statique (campagne, overlays).
/// Seul l'écran de jeu passe une valeur non nulle.
class GameBackground extends StatelessWidget {
  /// Décalage de défilement en pixels « monde » (progression lissée du joueur).
  /// 0 = fond immobile.
  final double scrollOffset;

  /// Hauteur, en bas de l'écran, occupée par de l'UI qui ne doit pas recouvrir
  /// la zone de roulage (zone de saisie + panneau de bonus en jeu, etc.).
  final double bottomReserved;

  /// Hauteur, en haut de l'écran, occupée par de l'UI qui ne doit pas être
  /// recouverte (header + timeline en jeu). `up` démarre juste en dessous.
  final double topReserved;

  /// Si vrai, la couche `up` est étirée jusqu'au tout haut de l'écran (y=0)
  /// sans changer la ride line / ligne de stage (toujours calées sur
  /// [topReserved]). Utilisé en campagne, où le fond doit remplir tout
  /// l'écran derrière le header alors que la piste, elle, reste calée sur
  /// le milieu des boutons premium.
  final bool stretchUpToTop;

  const GameBackground({
    super.key,
    this.scrollOffset = 0,
    this.bottomReserved = 0,
    this.topReserved = 0,
    this.stretchUpToTop = false,
  });

  static const String _upAsset = 'assets/images/background/game_bg_up.png';
  static const String _trackAsset = 'assets/images/background/game_bg_track.png';
  static const String _downAsset = 'assets/images/background/game_bg_down.png';

  // Ratios largeur/hauteur natifs des assets (px) : on étire chaque couche
  // uniquement en hauteur (géométrie de piste) et on garde ce ratio pour la
  // largeur, afin de ne jamais déformer l'image horizontalement. Les bords
  // gauche/droit des assets sont conçus pour se raccorder (bouclage).
  static const double _upAspect = 1095 / 553;
  static const double _downAspect = 1095 / 422;

  // Facteurs de parallaxe : l'avant-plan file plus vite que l'arrière-plan.
  static const double _upParallaxFactor = 0.35;
  static const double _downParallaxFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size.width <= 0 || size.height <= 0) {
          return const SizedBox.shrink();
        }

        final geo = raceTrackGeometry(
          size,
          bottomReserved: bottomReserved,
          topReserved: topReserved,
        );
        final double dpr = MediaQuery.of(context).devicePixelRatio;

        final double upHeight = stretchUpToTop ? geo.upBottomY : geo.upHeight;
        final double upImgWidth = upHeight * _upAspect;
        final double downImgWidth = geo.downHeight * _downAspect;

        return ClipRect(
          child: Stack(
            children: [
              // Arrière-plan : étiré en hauteur du haut de l'écran jusqu'à la
              // piste, largeur gardée à son ratio naturel (pas de déformation),
              // défilement lent. `stretchUpToTop` remonte le bord haut à 0 sans
              // bouger le seuil bas (couture avec `track` inchangée).
              _scrollingLayer(
                layerKey: const ValueKey('bg-up-layer'),
                asset: _upAsset,
                top: stretchUpToTop ? 0 : geo.upTopY,
                height: upHeight,
                screenWidth: size.width,
                imgWidth: upImgWidth,
                shift: _wrapShift(
                  scrollOffset * _upParallaxFactor,
                  upImgWidth,
                ),
                dpr: dpr,
              ),

              // Piste : fixe, une seule copie, étirée en hauteur. Dessinée
              // après `up` pour masquer la couture du bas de l'arrière-plan.
              Positioned(
                key: const ValueKey('bg-track-layer'),
                left: 0,
                top: geo.trackTopY,
                width: size.width,
                height: geo.trackHeight,
                child: Image.asset(
                  _trackAsset,
                  fit: BoxFit.fill,
                  cacheWidth: (size.width * dpr).round(),
                ),
              ),

              // Avant-plan : étiré en hauteur de la piste jusqu'au ras du
              // cartouche des lettres, largeur gardée à son ratio naturel,
              // défilement rapide. Dessiné en dernier pour masquer la couture
              // du bas de la piste.
              _scrollingLayer(
                layerKey: const ValueKey('bg-down-layer'),
                asset: _downAsset,
                top: geo.downTopY,
                height: geo.downHeight,
                screenWidth: size.width,
                imgWidth: downImgWidth,
                shift: _wrapShift(
                  scrollOffset * _downParallaxFactor,
                  downImgWidth,
                ),
                dpr: dpr,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Ramène un décalage brut dans l'intervalle [0, imgWidth[ pour le bouclage.
  static double _wrapShift(double raw, double imgWidth) {
    if (imgWidth <= 0) return 0;
    final double m = raw % imgWidth;
    return m < 0 ? m + imgWidth : m;
  }

  /// Une couche horizontale défilante, non déformée : chaque copie est
  /// rendue à [imgWidth] (ratio natif de l'asset étiré à [height]), posée à
  /// partir du bord gauche. Autant de copies que nécessaire sont juxtaposées
  /// (bords gauche/droit raccordés dans l'asset) pour couvrir [screenWidth] ;
  /// un éventuel dépassement à droite est sans conséquence (rogné par le
  /// `ClipRect` englobant).
  Widget _scrollingLayer({
    Key? layerKey,
    required String asset,
    required double top,
    required double height,
    required double screenWidth,
    required double imgWidth,
    required double shift,
    required double dpr,
  }) {
    if (imgWidth <= 0 || height <= 0) return const SizedBox.shrink();

    final int cacheWidth = (imgWidth * dpr).round();
    Widget img() => Image.asset(
      asset,
      width: imgWidth,
      height: height,
      fit: BoxFit.fill,
      cacheWidth: cacheWidth > 0 ? cacheWidth : null,
    );

    final int copies = (screenWidth / imgWidth).ceil() + 1;

    return Positioned(
      key: layerKey,
      left: 0,
      top: top,
      width: screenWidth,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < copies; i++)
            Positioned(
              left: i * imgWidth - shift,
              width: imgWidth,
              height: height,
              child: img(),
            ),
        ],
      ),
    );
  }
}
