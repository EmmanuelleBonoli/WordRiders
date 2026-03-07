# Word Riders

**Word Riders** est un jeu de puzzle de mots mobile développé avec [Flutter](https://flutter.dev) et le [Moteur Flame](https://flame-engine.org/). Les joueurs doivent former des mots en utilisant les lettres fournies pour alimenter leur train et faire la course jusqu'à la ligne d'arrivée.

## 🎮 Modes de Jeu

### Mode Campagne
Défiez un adversaire IA qui avance continuellement. La vitesse de l'IA s'adapte dynamiquement en fonction du niveau de difficulté du stage. Battez l'IA jusqu'à la ligne d'arrivée pour progresser !

### Mode Entraînement
Idéal pour se familiariser avec le jeu sans la pression du temps. Vous pouvez configurer les paramètres de votre entraînement pour vous améliorer à votre propre rythme et découvrir de nouveaux mots.

## ✨ Fonctionnalités Principales

### Objectifs Quotidiens et de Carrière
Accomplissez des défis journaliers (comme trouver des mots longs) ou des objectifs à long terme (comme terminer des niveaux) pour obtenir des pièces.

### Boutique (Store) et Boosters
Dépensez vos pièces durement gagnées dans la boutique pour acheter des boosters utiles en partie :
- Lettres supplémentaires pour débloquer des situations difficiles
- Distance doublée pour rattraper l'adversaire
- Gel du rival pour bloquer temporairement l'IA

### Vies Régénératrices
Vous disposez de 5 vies, l'une d'elles se régénère toutes les 20 minutes en cas de défaite. Un système de "Vies Illimitées" temporaires (gagnable ou achetable) est également présent.

## 🛠 Stack Technique

- **Framework**: Flutter 3.38.7
- **Moteur de Jeu**: Flame 1.33.0
- **Gestion d'État**: Provider 6.1.5
- **Navigation**: GoRouter 17.0.1
- **Localisation**: EasyLocalization (Anglais & Français)
- **Architecture**: Structure orientée fonctionnalités (Feature-first)
- **Télémétrie & Crashs**: Firebase Analytics & Firebase Crashlytics
- **CI/CD**: GitHub Actions

## 📂 Structure du Projet

```text
lib/
├── config/         # Configurations globales et constantes de l'application
├── data/           # Fichiers de données statiques (listes audio, objectifs, etc.)
├── features/       # Modules basés sur les fonctionnalités réparties en domaines (gameplay, ui)
│   ├── gameplay/   # Logique interne du jeu (controllers, modèles de composants, services)
│   └── ui/         # Interfaces visuelles du jeu (écrans, popups, widgets)
├── main.dart       # Point d'entrée de l'application
├── router.dart     # Configuration de la navigation par routes (GoRouter)
└── secrets.dart    # Fichier stockant les clés de l'environnement (exclut de Git)
```

## 🚀 Pour Commencer

Ce projet est un point de départ pour une application Flutter.

### Prérequis
- SDK Flutter
- SDK Dart

### Installation

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/EmmanuelleBonoli/wordRiders.git
   ```
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. **Configuration des clés API (Secrets)** :
   Pour des raisons de sécurité, les clés API de Firebase ne sont pas incluses dans le dépôt GitHub.
   Vous devez copier le fichier d'exemple et y insérer vos propres clés :
   ```bash
   cp lib/secrets_sample.dart lib/secrets.dart
   ```
   *Note : Vous devrez également configurer Firebase pour votre propre projet en remplaçant `firebase_sample.json` et `android/app/google-services-sample.json` si vous souhaitez utiliser Crashlytics et Analytics.*

4. Lancer l'application :
   ```bash
   flutter run
   ```

## 🤖 Intégration Continue (CI)

Le projet utilise **GitHub Actions** pour vérifier automatiquement le bon fonctionnement du code à chaque *Pull Request* vers les branches `staging` et `main`. 
La CI exécute automatiquement :
- L'installation des dépendances (`flutter pub get`)
- L'injection des faux secrets pour la compilation (`lib/secrets.dart`)
- L'analyse du code (`flutter analyze`)
- L'exécution des tests unitaires (`flutter test`)

## 🌐 Localisation

L'application supporte l'Anglais (`en`) et le Français (`fr`). Les traductions se trouvent dans le dossier `assets/translations/`.
