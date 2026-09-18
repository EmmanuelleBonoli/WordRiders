import 'dart:ui' show Size;

// --- Constantes de calage vertical (px logiques / ratios, ajustées sur device) ---
// Position de la ride line dans la zone utile (haut → haut du cartouche des
// lettres). 0 = tout en haut, 1 = au ras du cartouche.
const double _kRideLineFraction = 0.56;
// Bord haut de `down` juste sous la ride line : les persos roulent sur la piste,
// devant l'avant-plan.
const double _kDownTopBelowRide = 16.0;
// Hauteur de piste visible au-dessus de la ride line.
const double _kTrackAboveRide = 48.0;
// Chevauchement piste / `up` pour masquer la couture.
const double _kLayerOverlap = 4.0;
// La piste passe sous `down` d'au moins ce ratio de la hauteur de `down`
// (sinon une bande blanche apparaît à la jonction).
const double _kTrackUnderDownRatio = 0.12;
const double _kTrackUnderDownMin = 24.0;
// Garde-fous petits écrans.
const double _kMinDownHeight = 60.0;
const double _kMinUpHeight = 60.0;

/// Distance verticale entre la ride line et la ligne de stage (campagne). La
/// ligne de stage tombe ainsi SUR l'image du bas. Exposé pour que
/// `campaign_preview_game` place le joueur exactement sur la même ride line.
const double kRaceTrackRideLineToStageLine = 56.0;

/// Géométrie verticale de la piste de course, partagée entre l'écran de jeu,
/// l'écran de campagne et les overlays.
///
/// Modèle : `up` (arrière-plan) et `down` (avant-plan) sont **étirés** pour
/// remplir l'écran de haut en bas ; `track` est une bande fixe à leur jonction,
/// qui chevauche `up` en haut et passe sous `down` en bas. La piste peinte
/// tombe sur [rideLineY], quel que soit le ratio de l'écran.
///
/// Toutes les valeurs sont en pixels logiques, dans le repère de l'élément qui
/// rend le fond plein cadre (origine en haut à gauche).
class RaceTrackGeometry {
  /// Ordonnée du haut de la couche `up`.
  final double upTopY;

  /// Hauteur rendue de `up` (étirée : bord bas au chevauchement avec la piste).
  final double upHeight;

  /// Ordonnée du haut de la couche `track` (chevauche le bas de `up`).
  final double trackTopY;

  /// Hauteur rendue de la couche `track`.
  final double trackHeight;

  /// Ordonnée du haut de la couche `down`, juste sous la ride line.
  final double downTopY;

  /// Hauteur rendue de `down` (étirée : bord bas au ras du cartouche des lettres).
  final double downHeight;

  /// Ordonnée de la ligne de roulage : roues des personnages, jeu et campagne.
  final double rideLineY;

  /// Ordonnée de la ligne de stage (cercles + trait) de l'écran de campagne.
  /// Située SUR l'image du bas (`downTopY < stageLineY < downBottomY`).
  final double stageLineY;

  const RaceTrackGeometry({
    required this.upTopY,
    required this.upHeight,
    required this.trackTopY,
    required this.trackHeight,
    required this.downTopY,
    required this.downHeight,
    required this.rideLineY,
    required this.stageLineY,
  });

  /// Ordonnée du bas de la couche `up`.
  double get upBottomY => upTopY + upHeight;

  /// Ordonnée du bas de la couche `track` (passe sous le haut de `down`).
  double get trackBottomY => trackTopY + trackHeight;

  /// Ordonnée du bas de la couche `down` (au ras du cartouche des lettres).
  double get downBottomY => downTopY + downHeight;
}

/// Calcule la géométrie verticale de la piste pour un écran de taille [screen].
///
/// [bottomReserved] : hauteur, en bas, occupée par de l'UI à ne pas recouvrir
/// (cartouche des lettres + panneau de bonus en jeu, barre de navigation en
/// campagne, 0 pour les overlays). `down` s'arrête pile à cette limite.
///
/// [topReserved] : hauteur, en haut, à laisser libre avant de démarrer `up`
/// (0 = `up` démarre tout en haut de l'écran).
RaceTrackGeometry raceTrackGeometry(
  Size screen, {
  double bottomReserved = 0,
  double topReserved = 0,
}) {
  final double h = screen.height;
  final double top = topReserved.clamp(0.0, h);
  final double effectiveBottom = (h - bottomReserved).clamp(top + 1, h);
  final double avail = effectiveBottom - top;

  // Ride line : fraction de la zone utile.
  final double rideLineY = top + avail * _kRideLineFraction;

  // `down` : étirée de (ride line + marge) jusqu'au cartouche des lettres.
  final double downBottomY = effectiveBottom;
  double downTopY = rideLineY + _kDownTopBelowRide;
  if (downBottomY - downTopY < _kMinDownHeight) {
    downTopY = downBottomY - _kMinDownHeight;
  }
  final double downHeight = downBottomY - downTopY;

  // `track` : bande fixe. Chevauche `up` en haut, passe sous `down` en bas
  // d'au moins _kTrackUnderDownRatio de la hauteur de `down`.
  final double underDown = (downHeight * _kTrackUnderDownRatio)
      .clamp(_kTrackUnderDownMin, downHeight);
  final double trackBottomY = downTopY + underDown;
  double trackTopY = rideLineY - _kTrackAboveRide;
  if (trackTopY < top) trackTopY = top;
  final double trackHeight = (trackBottomY - trackTopY).clamp(1.0, h);

  // `up` : étirée du haut jusqu'au chevauchement avec la piste.
  final double upTopY = top;
  double upBottomY = trackTopY + _kLayerOverlap;
  if (upBottomY - upTopY < _kMinUpHeight) {
    upBottomY = upTopY + _kMinUpHeight;
  }
  final double upHeight = upBottomY - upTopY;

  // Campagne : ligne de stage enfoncée dans `down`.
  final double stageLineY = rideLineY + kRaceTrackRideLineToStageLine;

  return RaceTrackGeometry(
    upTopY: upTopY,
    upHeight: upHeight,
    trackTopY: trackTopY,
    trackHeight: trackHeight,
    downTopY: downTopY,
    downHeight: downHeight,
    rideLineY: rideLineY,
    stageLineY: stageLineY,
  );
}
