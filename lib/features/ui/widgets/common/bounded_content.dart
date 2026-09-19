import 'package:flutter/widgets.dart';

/// Tailles de référence pour la largeur maximale du contenu, afin que
/// l'interface reste lisible et proportionnée sur grand écran/tablette au
/// lieu de s'étirer sur toute la largeur disponible.
enum ContentWidth {
  /// Colonne de boutons de menu.
  menu(300),

  /// Contenu de page standard (paramètres, listes, trophées...).
  standard(600),

  /// Modales et overlays de jeu.
  modal(480);

  const ContentWidth(this.maxWidth);

  final double maxWidth;
}

/// Raccourci pour détecter un affichage "grand écran", où les modales et
/// overlays de jeu doivent flotter au centre plutôt qu'occuper tout l'écran.
extension ContentWidthContext on BuildContext {
  bool get isFloatingModal =>
      MediaQuery.of(this).size.width > ContentWidth.modal.maxWidth;
}

/// Limite la largeur de [child] et le centre horizontalement.
///
/// Utiliser [width] pour une des tailles de référence [ContentWidth], ou
/// [explicitMaxWidth] pour un besoin ponctuel qui ne correspond à aucun
/// token existant.
class BoundedContent extends StatelessWidget {
  final ContentWidth? width;
  final double? explicitMaxWidth;
  final Widget child;

  const BoundedContent({
    super.key,
    this.width,
    this.explicitMaxWidth,
    required this.child,
  }) : assert(
         (width == null) != (explicitMaxWidth == null),
         'Fournir soit width, soit explicitMaxWidth (exclusif).',
       );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width?.maxWidth ?? explicitMaxWidth!,
        ),
        child: child,
      ),
    );
  }
}
