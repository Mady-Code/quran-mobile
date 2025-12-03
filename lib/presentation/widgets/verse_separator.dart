import 'package:flutter/material.dart';
import '../../data/models/verse.dart';

class VerseSeparator extends StatelessWidget {
  final Verse verse;
  final Color? color;

  const VerseSeparator({
    super.key,
    required this.verse,
    this.color,
  });

  String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final verseNumber = verse.verseKey.split(':')[1];
    final arabicVerseNumber = _toArabicDigits(verseNumber);
    
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ayah End Symbol
          Text(
            '\u06DD',
            style: TextStyle(
              fontFamily: 'KFGQPC Uthmanic Script HAFS',
              fontSize: 32,
              color: color ?? const Color(0xFFD4AF37), // Gold color default
              height: 1.0,
            ),
          ),
          // Verse Number
          Padding(
            padding: const EdgeInsets.only(top: 4), // Slight adjustment for centering
            child: Text(
              arabicVerseNumber,
              style: TextStyle(
                fontFamily: 'KFGQPC Uthmanic Script HAFS',
                fontSize: 12, // Smaller font for number inside
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
