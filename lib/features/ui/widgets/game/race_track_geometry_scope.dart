import 'package:flutter/widgets.dart';

import 'race_track_geometry.dart';

/// Diffuse la géométrie de piste (calculée en repère écran par `MainLayout`)
/// et l'offset vertical de la zone de contenu de campagne à ses descendants.
///
/// `CampaignProgressScreen` s'en sert pour poser la ligne de stage et le
/// personnage exactement sur la track peinte par `GameBackground`, sans avoir
/// à mesurer lui-même sa position dans l'écran.
class RaceTrackGeometryScope extends InheritedWidget {
  /// Géométrie de piste plein écran (repère écran, origine en haut à gauche).
  final RaceTrackGeometry geometry;

  /// Ordonnée, en repère écran, du haut de la zone de contenu de campagne.
  /// Sert à convertir les valeurs de [geometry] en repère local du contenu.
  final double contentTop;

  const RaceTrackGeometryScope({
    super.key,
    required this.geometry,
    required this.contentTop,
    required super.child,
  });

  static RaceTrackGeometryScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RaceTrackGeometryScope>();
  }

  @override
  bool updateShouldNotify(RaceTrackGeometryScope oldWidget) {
    return oldWidget.contentTop != contentTop ||
        oldWidget.geometry.rideLineY != geometry.rideLineY ||
        oldWidget.geometry.stageLineY != geometry.stageLineY;
  }
}
