import 'package:hive/hive.dart';
import '../../../features/quran/domain/entities/recitation.dart';

part 'recitation_cache_model.g.dart';

@HiveType(typeId: 2)
class RecitationCacheModel {
  @HiveField(0)
  final int chapterId;

  @HiveField(1)
  final String audioUrl;

  @HiveField(2)
  final String reciterName;

  @HiveField(3)
  final String edition;

  RecitationCacheModel({
    required this.chapterId,
    required this.audioUrl,
    required this.reciterName,
    required this.edition,
  });

  Recitation toEntity() {
    return Recitation(
      chapterId: chapterId,
      audioUrl: audioUrl,
      reciterName: reciterName,
      edition: edition,
    );
  }

  factory RecitationCacheModel.fromEntity(Recitation recitation) {
    return RecitationCacheModel(
      chapterId: recitation.chapterId,
      audioUrl: recitation.audioUrl,
      reciterName: recitation.reciterName,
      edition: recitation.edition,
    );
  }
}
