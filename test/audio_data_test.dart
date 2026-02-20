import 'package:flutter_test/flutter_test.dart';
import 'package:word_riders/data/audio_data.dart';

void main() {
  group('AudioData Tests', () {
    test('Tous les fichiers audio doivent se trouver dans le dossier "sounds/"', () {
      for (final audioPath in AudioData.allAudio) {
        expect(audioPath.startsWith('sounds/'), isTrue, 
            reason: 'Le fichier $audioPath ne commence pas par "sounds/"');
      }
    });

    test('Tous les fichiers audio doivent être au format .mp3', () {
      for (final audioPath in AudioData.allAudio) {
        expect(audioPath.endsWith('.mp3'), isTrue, 
            reason: 'Le fichier $audioPath n\'est pas un fichier .mp3');
      }
    });

    test('Il ne doit pas y avoir de doublons dans la liste de préchargement', () {
      final uniqueAudios = AudioData.allAudio.toSet();
      expect(uniqueAudios.length, equals(AudioData.allAudio.length), 
          reason: 'La liste allAudio contient des fichiers en double');
    });
  });
}
