import 'package:audioplayers/audioplayers.dart';
import 'package:word_riders/data/audio_data.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';

class AudioService {
  // Singleton pour un accès global
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    // Configurer la musique pour qu'elle tourne en boucle
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  final AudioPlayer _musicPlayer = AudioPlayer();
  
  // Garder en mémoire la musique actuelle pour éviter de la relancer inutilement
  String? _currentMusic;

  // Précharge tous les sons en mémoire, lancé au démarrage du jeu
  Future<void> preloadAll() async {
    await AudioCache.instance.loadAll(AudioData.allAudio);
  }

  // Lance ou change la musique de fond
  Future<void> playMusic(String musicAssetPath) async {
    final isEnabled = await PlayerPreferences.isMusicEnabled();
    if (!isEnabled) {
      await stopMusic();
      return;
    }

    if (_currentMusic == musicAssetPath && _musicPlayer.state == PlayerState.playing) {
      return; // Déjà en cours de lecture
    }

    _currentMusic = musicAssetPath;
    await _musicPlayer.play(AssetSource(musicAssetPath));
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // Met la musique en pause (utile pour les pubs)
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  // Reprend la musique
  Future<void> resumeMusic() async {
    final isEnabled = await PlayerPreferences.isMusicEnabled();
    if (isEnabled && _currentMusic != null) {
      await _musicPlayer.resume();
    }
  }

  // Joue un effet sonore unique (peut se superposer)
  Future<void> playSfx(String sfxAssetPath) async {
    final isEnabled = await PlayerPreferences.isSfxEnabled();
    if (!isEnabled) return;

    // Créer un lecteur temporaire pour les sons qui se superposent (frappe rapide au clavier par ex)
    final player = AudioPlayer();
    await player.play(AssetSource(sfxAssetPath));
    // Détruire le lecteur automatiquement une fois le son terminé pour libérer la mémoire
    player.onPlayerComplete.listen((_) {
      player.dispose();
    });
  }

  // Met à jour l'état. À appeler quand l'utilisateur change les réglages audio
  Future<void> validateAudioSettings() async {
    final isEnabled = await PlayerPreferences.isMusicEnabled();
    if (!isEnabled) {
      await stopMusic();
    } else if (_currentMusic != null) {
      await playMusic(_currentMusic!);
    }
  }

  // Libération globale des ressources
  void dispose() {
    _musicPlayer.dispose();
  }
}
