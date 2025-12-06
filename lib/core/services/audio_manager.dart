
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();
  
  // Base URL for audio (Mishary Rashid Alafasy - standard)
  final String _baseUrl = "https://server8.mp3quran.net/afs/";

  // Expose player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // Verify and download audio for a specific Ayah
  Future<String?> getAudioPath(int surahId, int ayahNum) async {
    final directory = await getApplicationDocumentsDirectory();
    final String paddedSurah = surahId.toString().padLeft(3, '0');
    final String paddedAyah = ayahNum.toString().padLeft(3, '0');
    final String fileName = "$paddedSurah$paddedAyah.mp3";
    final String dirPath = '${directory.path}/audio/$paddedSurah';
    final File file = File('$dirPath/$fileName');

    if (await file.exists()) {
      return file.path;
    } else {
      // Create directory if not exists
      await Directory(dirPath).create(recursive: true);
      // Download if not exists
      return await _downloadAudio(surahId, ayahNum, file);
    }
  }

  Future<String?> _downloadAudio(int surahId, int ayahNum, File targetFile) async {
    try {
      final String paddedSurah = surahId.toString().padLeft(3, '0');
      final String paddedAyah = ayahNum.toString().padLeft(3, '0');
      final Uri url = Uri.parse("$_baseUrl$paddedSurah$paddedAyah.mp3");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        await targetFile.writeAsBytes(response.bodyBytes);
        return targetFile.path;
      } else {
        print("Failed to download audio: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error downloading audio: $e");
      return null;
    }
  }

  Future<void> playAyah(int surahId, int ayahNum) async {
    try {
      final path = await getAudioPath(surahId, ayahNum);
      if (path != null) {
        await _player.setFilePath(path);
        await _player.play();
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }
}
