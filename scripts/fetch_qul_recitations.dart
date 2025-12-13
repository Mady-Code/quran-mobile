import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Small helper script (à lancer en dehors de l’app Flutter) pour :
///  - récupérer la liste des récitateurs depuis QUL
///  - télécharger pour chacun le fichier JSON de récitation
///  - générer deux choses dans ce projet :
///    * assets/json/read/qul_reciters.json : liste des récitateurs
///    * assets/json/read/qul/<id>.json : données de récitation pour chaque id
///
/// Usage (dans le dossier racine du projet) :
///   dart run scripts/fetch_qul_recitations.dart
///
/// NB : ce script fait des appels réseau vers https://qul.tarteel.ai.

Future<void> main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://qul.tarteel.ai',
    // QUL renvoie du HTML pour /resources/recitation
    responseType: ResponseType.plain,
  ));

  final outputDir = Directory('assets/json/read/qul');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  print('📥 Fetching reciters index page from QUL...');
  final indexResponse = await dio.get<String>('/resources/recitation');
  final html = indexResponse.data ?? '';

  // Extraction très simple basée sur le HTML actuel de QUL :
  // On cherche les liens /resources/recitation/<id> et le texte du nom.
  //
  // Exemple HTML approximatif (voir aussi la page QUL) :
  //   <a href="/resources/recitation/411">Mishari Rashid al-`Afasy</a>
  //
  // On ne fait pas un parseur HTML complet, mais un RegExp robuste.

  final reciterRegex = RegExp(
    r'href="/resources/recitation/(\d+)".*?>([^<]+)</a>',
    multiLine: true,
    dotAll: true,
  );

  final matches = reciterRegex.allMatches(html).toList();
  if (matches.isEmpty) {
    print('⚠️ Aucune entrée de réciteur trouvée dans le HTML QUL.');
    return;
  }

  final reciters = <Map<String, dynamic>>[];

  print('✅ Found ${matches.length} recitation entries on QUL page');

  for (final m in matches) {
    final id = m.group(1)!;
    final name = m.group(2)!.trim();

    // Filtre optionnel : si on veut uniquement les recitations "avec segments",
    // on peut vérifier la présence de "With segments" dans la même ligne / cellule.
    // Ici, on garde tout et on laissera l’app filtrer si besoin.

    print('➡️  Reciter id=$id, name=$name');

    reciters.add({
      'id': id,
      'name': name,
      // Les champs ci-dessous pourront être enrichis à partir du JSON QUL si besoin.
      'style': '',
      'format': '',
      'has_segments': true, // QUL expose cette info dans les tags; ici on suppose true.
    });

    // Téléchargement du JSON de récitation pour chaque id
    // QUL documente l’endpoint download.json comme dans :
    //   https://qul.tarteel.ai/resources/recitation/<id>/download.json
    try {
      print('   📥 Downloading JSON for recitation $id ...');
      final recitationResp = await dio.get('/resources/recitation/$id/download.json');
      final data = recitationResp.data;

      final outFile = File('${outputDir.path}/$id.json');
      await outFile.writeAsString(
        jsonEncode(data),
        flush: true,
      );
      print('   ✅ Saved to ${outFile.path}');
    } catch (e) {
      print('   ❌ Error downloading JSON for id=$id : $e');
    }
  }

  // Sauvegarde de la liste des récitateurs
  final recitersIndexFile = File('assets/json/read/qul_reciters.json');
  await recitersIndexFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(reciters),
    flush: true,
  );
  print('✅ Reciters index saved to ${recitersIndexFile.path}');
}


