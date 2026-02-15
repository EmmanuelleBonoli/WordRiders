# Word Train 🚂

**Word Train** est un jeu de puzzle de mots mobile développé avec [Flutter](https://flutter.dev) et le [Moteur Flame](https://flame-engine.org/). Les joueurs doivent former des mots en utilisant les lettres fournies pour alimenter leur train et faire la course jusqu'à la ligne d'arrivée.

## 🎮 Modes de Jeu

### Mode Campagne
Défiez un adversaire IA qui avance continuellement. La vitesse de l'IA s'adapte dynamiquement en fonction du niveau de difficulté du stage. Battez l'IA jusqu'à la ligne d'arrivée pour progresser !

## 🛠 Stack Technique

- **Framework**: Flutter 3.38.7
- **Moteur de Jeu**: Flame 1.33.0
- **Gestion d'État**: Provider 6.1.5
- **Navigation**: GoRouter 17.0.1
- **Localisation**: EasyLocalization (Anglais & Français)
- **Architecture**: Structure orientée fonctionnalités (Feature-first)

## 📂 Structure du Projet

```text
lib/
├── core/           # Configurations de base et logique partagée
├── features/       # Modules basés sur les fonctionnalités (gameplay, ui, etc.)
├── utils/          # Classes utilitaires (Dictionnaire, etc.)
├── main.dart       # Point d'entrée
└── router.dart     # Configuration de la navigation
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
3. Lancer l'application :
   ```bash
   flutter run
   ```

## 🌐 Localisation

L'application supporte l'Anglais (`en`) et le Français (`fr`). Les traductions se trouvent dans le dossier `assets/translations/`.
