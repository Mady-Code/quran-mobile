class Recitation {
  final int chapterId;
  final String audioUrl;
  final String reciterName;
  final String edition; // e.g., 'ar.alafasy'

  const Recitation({
    required this.chapterId,
    required this.audioUrl,
    required this.reciterName,
    required this.edition,
  });
}
