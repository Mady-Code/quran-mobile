import 'dart:io';
import 'package:http/http.dart' as http;

/// Script to download all 604 Mushaf page images from quran.com
/// Run with: dart run scripts/download_mushaf_images.dart
void main() async {
  const baseUrl = 'https://android.quran.com/data/width_1024';
  const outputDir = 'assets/images/pages';
  const totalPages = 604;

  // Create output directory if it doesn't exist
  final dir = Directory(outputDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
    print('Created directory: $outputDir');
  }

  print('Starting download of $totalPages Mushaf pages...');
  print('This may take several minutes depending on your connection.\n');

  int downloaded = 0;
  int failed = 0;

  for (int page = 1; page <= totalPages; page++) {
    final pageId = page.toString().padLeft(3, '0');
    final url = '$baseUrl/page$pageId.png';
    final outputPath = '$outputDir/page$pageId.png';

    // Skip if already exists
    if (await File(outputPath).exists()) {
      print('[$page/$totalPages] Skipping page$pageId.png (already exists)');
      downloaded++;
      continue;
    }

    try {
      print('[$page/$totalPages] Downloading page$pageId.png...');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await File(outputPath).writeAsBytes(response.bodyBytes);
        downloaded++;
        print('[$page/$totalPages] ✓ Downloaded page$pageId.png (${(response.bodyBytes.length / 1024).toStringAsFixed(1)} KB)');
      } else {
        failed++;
        print('[$page/$totalPages] ✗ Failed to download page$pageId.png (Status: ${response.statusCode})');
      }
    } catch (e) {
      failed++;
      print('[$page/$totalPages] ✗ Error downloading page$pageId.png: $e');
    }

    // Small delay to avoid overwhelming the server
    if (page % 10 == 0) {
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  print('\n' + '=' * 60);
  print('Download complete!');
  print('Successfully downloaded: $downloaded pages');
  print('Failed: $failed pages');
  print('Total size: ${await _calculateDirectorySize(outputDir)}');
  print('=' * 60);
}

Future<String> _calculateDirectorySize(String path) async {
  final dir = Directory(path);
  int totalSize = 0;

  await for (var entity in dir.list(recursive: true)) {
    if (entity is File) {
      totalSize += await entity.length();
    }
  }

  final mb = totalSize / (1024 * 1024);
  return '${mb.toStringAsFixed(2)} MB';
}
