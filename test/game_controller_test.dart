import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_riders/features/gameplay/controllers/game_controller.dart';
import 'package:word_riders/features/gameplay/services/word_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
      (ByteData? message) async {
        return const StandardMessageCodec().encodeMessage([null]);
      },
    );
  });

  setUp(() {
    // Initialise les SharedPreferences virtuellement pour les tests
    SharedPreferences.setMockInitialValues({});
  });

  group('GameController - Basic State Management', () {
    test('L\'état initial doit être Loading avant l\'initialisation', () {
      final controller = GameController(isCampaign: true, locale: 'fr', wordService: WordService());
      // Immédiatement après construction, il est en loading
      expect(controller.isLoading, isTrue);
      expect(controller.status, equals(GameStatus.loading));
    });

    test('onLetterTap ajoute bien une lettre au currentInput si le statut est "playing"', () async {
      final controller = GameController(isCampaign: true, locale: 'fr', wordService: WordService());
      
      // Attendre que l'initialisation asynchrone (dictionnaire) soit terminée
      while (controller.isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.currentInput, isEmpty);

      controller.onLetterTap('A');
      controller.onLetterTap('B');
      
      expect(controller.currentInput, equals('AB'));
    });

    test('onBackspace supprime la dernière lettre de currentInput', () async {
      final controller = GameController(isCampaign: true, locale: 'fr', wordService: WordService());
      while (controller.isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      controller.onLetterTap('C');
      controller.onLetterTap('H');
      controller.onLetterTap('A');
      controller.onLetterTap('T');
      expect(controller.currentInput, equals('CHAT'));

      controller.onBackspace();
      expect(controller.currentInput, equals('CHA'));
    });

    test('clearInput efface tout le mot en cours', () async {
      final controller = GameController(isCampaign: true, locale: 'fr', wordService: WordService());
      while (controller.isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      controller.onLetterTap('C');
      controller.onLetterTap('H');
      controller.onLetterTap('A');
      controller.onLetterTap('T');
      
      controller.clearInput();
      expect(controller.currentInput, isEmpty);
    });

    test('pauseGame gèle la partie et resumeGame la reprend', () async {
      final controller = GameController(isCampaign: true, locale: 'fr', wordService: WordService());
      while (controller.isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      expect(controller.isPaused, isFalse);

      controller.pauseGame();
      expect(controller.isPaused, isTrue);
      expect(controller.status, equals(GameStatus.paused));

      // Les interactions sont bloquées quand le jeu est en pause
      controller.onLetterTap('X');
      expect(controller.currentInput, isEmpty); 

      controller.resumeGame();
      expect(controller.isPaused, isFalse);
      expect(controller.status, equals(GameStatus.playing));
      
      // Les interactions reprennent
      controller.onLetterTap('X');
      expect(controller.currentInput, equals('X'));
    });
  });
}
