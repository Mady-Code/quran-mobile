class QulReciter {
  final String id;
  final String name;
  final String style;
  final String format; // 'Ayah by Ayah' or 'Surah by Surah'
  final bool hasSegments;
  
  const QulReciter({
    required this.id,
    required this.name,
    required this.style,
    required this.format,
    required this.hasSegments,
  });
}

class QulAyahRecitation {
  final int surah;
  final int ayah;
  final String audioUrl;
  final List<QulSegment> segments;
  
  const QulAyahRecitation({
    required this.surah,
    required this.ayah,
    required this.audioUrl,
    required this.segments,
  });
  
  factory QulAyahRecitation.fromJson(Map<String, dynamic> json) {
    return QulAyahRecitation(
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      audioUrl: json['audio_url'] as String,
      segments: (json['segments'] as List)
          .map((s) => QulSegment.fromList(s as List))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'surah': surah,
      'ayah': ayah,
      'audio_url': audioUrl,
      'segments': segments.map((s) => s.toList()).toList(),
    };
  }
}

class QulSurahRecitation {
  final int surah;
  final Map<String, QulAyahData> ayahs; // Key: "surah:ayah"
  
  const QulSurahRecitation({
    required this.surah,
    required this.ayahs,
  });
  
  factory QulSurahRecitation.fromJson(int surah, Map<String, dynamic> json) {
    final ayahs = <String, QulAyahData>{};
    
    json.forEach((key, value) {
      ayahs[key] = QulAyahData.fromJson(value as Map<String, dynamic>);
    });
    
    return QulSurahRecitation(
      surah: surah,
      ayahs: ayahs,
    );
  }
}

class QulAyahData {
  final List<QulSegment> segments;
  final int durationSec;
  final int durationMs;
  final int timestampFrom;
  final int timestampTo;
  
  const QulAyahData({
    required this.segments,
    required this.durationSec,
    required this.durationMs,
    required this.timestampFrom,
    required this.timestampTo,
  });
  
  factory QulAyahData.fromJson(Map<String, dynamic> json) {
    return QulAyahData(
      segments: (json['segments'] as List)
          .map((s) => QulSegment.fromList(s as List))
          .toList(),
      durationSec: json['duration_sec'] as int,
      durationMs: json['duration_ms'] as int,
      timestampFrom: json['timestamp_from'] as int,
      timestampTo: json['timestamp_to'] as int,
    );
  }
}

class QulSegment {
  final int index;
  final int startMs;
  final int endMs;
  
  const QulSegment({
    required this.index,
    required this.startMs,
    required this.endMs,
  });
  
  factory QulSegment.fromList(List<dynamic> list) {
    return QulSegment(
      index: list[0] as int,
      startMs: list[1] as int,
      endMs: list[2] as int,
    );
  }
  
  List<int> toList() {
    return [index, startMs, endMs];
  }
}
