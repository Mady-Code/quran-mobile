import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../features/quran/domain/entities/recitation.dart';
import '../api/alquran_api.dart';
import '../api/qul_service.dart';
import '../cache/models/qul_recitation_model.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  
  // Expose player state stream
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  // Playlist management
  ConcatenatingAudioSource? _playlist;

  Future<void> init() async {
    // Optional configuration can go here
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }
  
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
  
  Future<void> seekToNext() async {
    await _player.seekToNext();
  }

  Future<void> seekToPrevious() async {
    await _player.seekToPrevious();
  }


  // Current Recitation Data
  Recitation? _currentRecitation;
  QulAyahRecitation? _currentQulRecitation;
  int _currentSegmentIndex = -1;
  
  // Stream of current verse key based on audio position
  // Note: AlQuran.cloud provides full surah audio without verse-level timestamps
  // So we can't track individual verses anymore
  Stream<String?> get currentVerseStream => Stream.value(null);
  
  // Stream of current segment (for QUL word highlighting)
  Stream<int?> get currentSegmentStream => _player.positionStream.map((position) {
    if (_currentQulRecitation == null) return null;
    
    final ms = position.inMilliseconds;
    
    // Find current segment
    for (var i = 0; i < _currentQulRecitation!.segments.length; i++) {
      final segment = _currentQulRecitation!.segments[i];
      if (ms >= segment.startMs && ms <= segment.endMs) {
        if (_currentSegmentIndex != i) {
          _currentSegmentIndex = i;
        }
        return i;
      }
    }
    return null;
  }).distinct();

  Future<String> _getLocalFilePath(int chapterId) async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/recitation_$chapterId.mp3';
  }

  Future<bool> isRecitationDownloaded(int chapterId) async {
    final path = await _getLocalFilePath(chapterId);
    return File(path).exists();
  }

  Future<void> downloadRecitation(Recitation recitation, {Function(int, int)? onReceiveProgress}) async {
    try {
      final path = await _getLocalFilePath(recitation.chapterId);
      final dio = Dio(); // Ideally use injected Dio
      await dio.download(
        recitation.audioUrl, 
        path,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      print("Download error: $e");
      rethrow;
    }
  }

  Future<void> playRecitation(Recitation recitation, {
    String? title,
    String? artist,
    String? imageUrl,
  }) async {
    _currentRecitation = recitation;
    
    try {
      Uri audioUri;
      // Check for local file first
      if (await isRecitationDownloaded(recitation.chapterId)) {
        final path = await _getLocalFilePath(recitation.chapterId);
        audioUri = Uri.file(path);
        print('🎵 Playing from local file: $path');
        await _playFromUri(audioUri);
        return;
      }

      // Play from primary CDN (full surah)
      audioUri = Uri.parse(recitation.audioUrl);
      print('🎵 Playing from URL: ${recitation.audioUrl}');
      await _playFromUri(audioUri);
      print('✅ Playback started successfully');
    } catch (e) {
      print("❌ Error playing recitation: $e");
      print("� Tip: Check your internet connection or try a different WiFi network");
      rethrow;
    }
  }

  Future<void> _playFromUri(Uri audioUri) async {
    // Simple audio source without MediaItem (no background notifications)
    final audioSource = AudioSource.uri(audioUri);
    
    print('🎵 Setting audio source...');
    await _player.setAudioSource(audioSource);
    print('🎵 Starting playback...');
    await _player.play();
  }
  
  /// Play ayah with QUL segments for word-by-word highlighting
  Future<void> playAyahWithSegments(
    int surah,
    int ayah,
    String reciterId,
    QulAyahRecitation recitationData,
  ) async {
    _currentQulRecitation = recitationData;
    _currentSegmentIndex = -1;
    
    try {
      final qulService = QulService();
      final audioUrl = qulService.getAyahAudioUrl(reciterId, surah, ayah);
      
      print('🎵 Playing ayah $surah:$ayah with ${recitationData.segments.length} segments');
      print('🎵 Audio URL: $audioUrl');
      
      final audioSource = AudioSource.uri(Uri.parse(audioUrl));
      await _player.setAudioSource(audioSource);
      await _player.play();
      
      print('✅ Playback started with word-by-word highlighting enabled');
    } catch (e) {
      print('❌ Error playing ayah with segments: $e');
      rethrow;
    }
  }

  bool get isPlaying => _player.playing;

  void dispose() {
    _player.dispose();
  }
}
