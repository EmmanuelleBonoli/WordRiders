import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_riders/features/ui/widgets/game/game_background.dart';

void main() {
  group('GameBackground', () {
    const Size testSurfaceSize = Size(390, 844);

    Future<void> pumpAt(WidgetTester tester, {double scrollOffset = 0}) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GameBackground(scrollOffset: scrollOffset),
        ),
      );
    }

    testWidgets('doit rendre les 3 couches sans déformation horizontale', (
      tester,
    ) async {
      // Arrange / Act
      await pumpAt(tester);

      // Assert : track = 1 copie unique, étirée pleine largeur (aplat).
      final trackImages = tester.widgetList<Image>(
        find.descendant(
          of: find.byKey(const ValueKey('bg-track-layer')),
          matching: find.byType(Image),
        ),
      );
      expect(trackImages, hasLength(1));
      final trackPositioned = tester.widget<Positioned>(
        find.byKey(const ValueKey('bg-track-layer')),
      );
      expect(trackPositioned.width, testSurfaceSize.width);

      // Assert : up/down affichent au moins une copie, jamais étirée à la
      // largeur écran (ratio natif conservé, pas de déformation).
      final upImages = tester.widgetList<Image>(
        find.descendant(
          of: find.byKey(const ValueKey('bg-up-layer')),
          matching: find.byType(Image),
        ),
      );
      final downImages = tester.widgetList<Image>(
        find.descendant(
          of: find.byKey(const ValueKey('bg-down-layer')),
          matching: find.byType(Image),
        ),
      );
      expect(upImages, isNotEmpty);
      expect(downImages, isNotEmpty);
      expect(
        upImages.every((img) => img.width != testSurfaceSize.width),
        isTrue,
      );
      expect(
        downImages.every((img) => img.width != testSurfaceSize.width),
        isTrue,
      );
    });

    testWidgets('doit décaler les couches défilantes quand scrollOffset varie', (
      tester,
    ) async {
      // Arrange
      await pumpAt(tester);
      final double leftAtZero = tester
          .getTopLeft(
            find
                .descendant(
                  of: find.byKey(const ValueKey('bg-down-layer')),
                  matching: find.byType(Image),
                )
                .first,
          )
          .dx;

      // Act
      await pumpAt(tester, scrollOffset: 250);
      final double leftAfterScroll = tester
          .getTopLeft(
            find
                .descendant(
                  of: find.byKey(const ValueKey('bg-down-layer')),
                  matching: find.byType(Image),
                )
                .first,
          )
          .dx;

      // Assert : le décalage déplace bien la couche (parallaxe avant-plan).
      expect(leftAfterScroll, isNot(leftAtZero));
    });

    testWidgets('doit rester silencieux si la taille est nulle', (tester) async {
      // Arrange / Act : `Center` donne des contraintes lâches, la `SizedBox`
      // peut donc réellement s'effondrer à 0x0.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(width: 0, height: 0, child: GameBackground()),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
