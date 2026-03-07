import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:word_riders/data/audio_data.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';

class AudioService with WidgetsBindingObserver {
  // Singleton pour un accès global
  static AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  @visibleForTesting
  static void setMockInstance(AudioService mock) {
    _instance = mock;
  }
  
  @visibleForTesting
  AudioService.test();
  
  AudioService._internal() {
    _musicPlayer = AudioPlayer();
    _sfxPlayers = List.generate(
      _poolSize, 
      (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop)
    );
    try {
      AudioPlayer.global.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.none,
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
        ),
        iOS: AudioContextIOS(
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ));
    } catch (e) {
      // Ignoré lors des tests unitaires car le code natif n'est pas disponible.
    }
    
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      // Pause globale de l'audio quand l'app passe en arrière-plan
      if (_musicPlayer.state == PlayerState.playing) {
        _musicPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Relance de la musique quand l'app revient au premier plan
      if (_isMusicEnabled && _currentMusic != null) {
        _musicPlayer.resume();
      }
    }
  }
  late final AudioPlayer _musicPlayer;
  
  // Utiliser un pool de lecteurs SFX persistant pour éliminer totalement la latence
  // de la création systématique d'objets côté natif.
  static const int _poolSize = 5;
  late final List<AudioPlayer> _sfxPlayers;
  
  int _sfxIndex = 0;

  // Cache synchrone des paramètres pour ne plus faire de vérification async 
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  String? _currentMusic;

  // Précharge tous les sons en mémoire, lancé au démarrage du jeu
  Future<void> preloadAll() async {
    // 1. Initialiser le cache des préférences
    _isMusicEnabled = await PlayerPreferences.isMusicEnabled();
    _isSfxEnabled = await PlayerPreferences.isSfxEnabled();

    // 2. Configurer le player musical
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);

    // 3. Charger le cache d'actifs audio en mémoire
    try {
      await AudioCache.instance.loadAll(AudioData.allAudio);
    } catch (e) {
      debugPrint("AudioServices: Échec du chargement dans l'AudioCache -> $e");
    }
  }

  // Lance ou change la musique de fond
  Future<void> playMusic(String musicAssetPath) async {
    if (!_isMusicEnabled) {
      await stopMusic();
      return;
    }

    if (_currentMusic == musicAssetPath && _musicPlayer.state == PlayerState.playing) {
      return; // Déjà en cours de lecture
    }

    _currentMusic = musicAssetPath;
    await _musicPlayer.stop();
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
    if (_isMusicEnabled && _currentMusic != null) {
      await _musicPlayer.resume();
    }
  }

  Future<void> playSfx(String sfxAssetPath) async {
    if (!_isSfxEnabled) return;

    final player = _sfxPlayers[_sfxIndex];
    // Rotation circulaire dans le pool de lecteurs
    _sfxIndex = (_sfxIndex + 1) % _poolSize;
    
    try {
      if (player.state == PlayerState.playing) {
        // Si ce lecteur joue encore, on le coupe juste avant pour en relancer un
        await player.stop();
      }
      await player.play(AssetSource(sfxAssetPath));
    } catch (e) {
      // Ignorer silencieusement les erreurs de lecture audio (ex: Spam de clics rapides sur Android)
      debugPrint("AudioService: Échec de la lecture SFX ($sfxAssetPath) -> $e");
    }
  }

  // Met à jour l'état. À appeler quand l'utilisateur change les réglages audio
  Future<void> validateAudioSettings() async {
    _isMusicEnabled = await PlayerPreferences.isMusicEnabled();
    _isSfxEnabled = await PlayerPreferences.isSfxEnabled();
    
    if (!_isMusicEnabled) {
      await stopMusic();
    } else if (_currentMusic != null) {
      await playMusic(_currentMusic!);
    }
  }

  // Libération globale des ressources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _musicPlayer.dispose();
    for (var player in _sfxPlayers) {
      player.dispose();
    }
  }
}
