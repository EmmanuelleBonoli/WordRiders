import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:word_riders/features/ui/widgets/game/race_track_geometry.dart';

void main() {
  group('raceTrackGeometry', () {
    // Quelques tailles représentatives : téléphone allongé, téléphone standard,
    // tablette proche du 4:3.
    const tailles = <Size>[
      Size(390, 844), // iPhone ~19.5:9
      Size(360, 800), // Android standard
      Size(412, 915), // Android grand
      Size(768, 1024), // tablette 3:4
      Size(834, 1112), // tablette large
    ];

    test('doit placer la ride line à l\'intérieur de l\'écran', () {
      for (final taille in tailles) {
        final geo = raceTrackGeometry(taille, bottomReserved: taille.height * 0.3);

        expect(geo.rideLineY, greaterThan(0), reason: 'trop haut pour $taille');
        expect(geo.rideLineY, lessThan(taille.height),
            reason: 'trop bas pour $taille');
      }
    });

    test('doit étirer `up` et `down` avec la hauteur de l\'écran', () {
      // Arrange
      const largeur = 390.0;
      const bottom = 220.0;
      final petit = raceTrackGeometry(const Size(largeur, 700),
          bottomReserved: bottom);
      final grand = raceTrackGeometry(const Size(largeur, 1100),
          bottomReserved: bottom);

      // Assert : les deux couches encaissent la hauteur supplémentaire.
      expect(grand.upHeight, greaterThan(petit.upHeight + 100));
      expect(grand.downHeight, greaterThan(petit.downHeight + 100));
    });

    test('doit poser le bas de `down` au ras de l\'espace réservé', () {
      for (final taille in tailles) {
        const bottom = 200.0;
        final geo = raceTrackGeometry(taille, bottomReserved: bottom);

        expect(geo.downBottomY, closeTo(taille.height - bottom, 0.001),
            reason: '`down` ne descend pas jusqu\'au cartouche pour $taille');
      }
    });

    test('doit faire passer la piste sous `down` d\'au moins 10% de sa hauteur',
        () {
      for (final taille in tailles) {
        final geo =
            raceTrackGeometry(taille, bottomReserved: taille.height * 0.28);

        final double sousDown = geo.trackBottomY - geo.downTopY;
        expect(sousDown, greaterThanOrEqualTo(geo.downHeight * 0.10),
            reason: 'bande blanche possible sous `down` pour $taille');
      }
    });

    test('doit placer la ligne de stage SUR l\'image du bas', () {
      for (final taille in tailles) {
        final geo =
            raceTrackGeometry(taille, bottomReserved: taille.height * 0.28);

        expect(geo.stageLineY, greaterThan(geo.downTopY),
            reason: 'ligne de stage au-dessus de `down` pour $taille');
        expect(geo.stageLineY, lessThan(geo.downBottomY),
            reason: 'ligne de stage sous `down` pour $taille');
      }
    });

    test('doit garder la ride line au-dessus du haut de `down` (persos sur la '
        'piste, pas sur l\'avant-plan)', () {
      for (final taille in tailles) {
        final geo =
            raceTrackGeometry(taille, bottomReserved: taille.height * 0.28);

        expect(geo.rideLineY, lessThan(geo.downTopY));
      }
    });

    test('doit chevaucher les couches de haut en bas', () {
      for (final taille in tailles) {
        final geo =
            raceTrackGeometry(taille, bottomReserved: taille.height * 0.28);

        expect(geo.trackTopY, lessThanOrEqualTo(geo.upBottomY),
            reason: '`up` et `track` disjoints pour $taille');
        expect(geo.trackBottomY, greaterThan(geo.downTopY),
            reason: '`track` et `down` disjoints pour $taille');
      }
    });

    test('doit démarrer `up` en haut de l\'écran par défaut', () {
      final geo = raceTrackGeometry(const Size(390, 844), bottomReserved: 200);
      expect(geo.upTopY, 0);
    });

    test('doit décaler `up` de la hauteur réservée en haut', () {
      final geo = raceTrackGeometry(const Size(390, 844),
          bottomReserved: 200, topReserved: 90);
      expect(geo.upTopY, 90);
    });

    test('doit faire descendre la ride line quand on réserve de l\'espace en bas',
        () {
      const taille = Size(390, 844);
      final sansReserve = raceTrackGeometry(taille);
      final avecReserve = raceTrackGeometry(taille, bottomReserved: 200);

      expect(avecReserve.rideLineY, lessThan(sansReserve.rideLineY));
    });
  });
}
