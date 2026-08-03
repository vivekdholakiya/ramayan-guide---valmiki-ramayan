import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform

  );
  runApp(const RamayanUploadApp());
}

class RamayanUploadApp extends StatelessWidget {
  const RamayanUploadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valmiki Ramayan - Firebase Data Upload',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange, useMaterial3: true),
      home: const UploadHomePage(),
    );
  }
}

/// -----------------------------------------------------------------------
/// CATEGORY CONFIG
/// -----------------------------------------------------------------------
/// The uploaded JSON (assets/data/ramayan_gu.json) has this shape:
///
///   "ids_language": { "gu": "id", "hi": "id_hi", "en": "id_en" }
///   "mainDataListWithID_gu": {
///       "id_1": "સાત કાંડ", "id_2": "ઋષિઓ", "id_3": "વાનરો",
///       "id_4": "રાક્ષસો", "id_5": "અન્ય પાત્રો", "id_6": "મુખ્ય સ્થળો",
///       "id_7": "મંદિરો", "id_8": "દિવ્ય અસ્ત્રો"
///   }
///   "id_1": ["બાલકાંડ", "અયોધ્યાકાંડ", ...]   <- ordered titles for category 1
///   "id_1_1": "એક સમયે મહર્ષિ વાલ્મીકિ ..."    <- detail paragraph for title #1
///   "id_1_2": "..."                            <- detail paragraph for title #2
///   ...and so on for id_2 / id_2_1.. through id_8 / id_8_1..
///
/// So: title = data[jsonListKey][i], description = data['{jsonListKey}_{i+1}'].
/// This was confirmed by inspecting the actual uploaded file (141 top-level
/// keys = 2 metadata keys + 8 title-lists + 131 detail paragraphs).
class CategoryConfig {
  final String jsonListKey; // e.g. "id_2" -> the title list in the JSON
  final String firestoreId; // e.g. "rishio" -> Firestore category doc id
  final String buttonLabel; // e.g. "Upload ઋષિઓ"

  const CategoryConfig({
    required this.jsonListKey,
    required this.firestoreId,
    required this.buttonLabel,
  });
}

const List<CategoryConfig> kCategories = [
  CategoryConfig(
    jsonListKey: 'id_1',
    firestoreId: 'sath_kand',
    buttonLabel: 'Upload સાત કાંડ',
  ),
  CategoryConfig(
    jsonListKey: 'id_2',
    firestoreId: 'rishio',
    buttonLabel: 'Upload ઋષિઓ',
  ),
  CategoryConfig(
    jsonListKey: 'id_3',
    firestoreId: 'vanaro',
    buttonLabel: 'Upload વાનરો',
  ),
  CategoryConfig(
    jsonListKey: 'id_4',
    firestoreId: 'rakshaso',
    buttonLabel: 'Upload રાક્ષસો',
  ),
  CategoryConfig(
    jsonListKey: 'id_5',
    firestoreId: 'anya_patrono',
    buttonLabel: 'Upload અન્ય પાત્રો',
  ),
  CategoryConfig(
    jsonListKey: 'id_6',
    firestoreId: 'mukhya_sthalo',
    buttonLabel: 'Upload મુખ્ય સ્થળો',
  ),
  CategoryConfig(
    jsonListKey: 'id_7',
    firestoreId: 'temples',
    buttonLabel: 'Upload Temples',
  ),
  CategoryConfig(
    jsonListKey: 'id_8',
    firestoreId: 'divya_astro',
    buttonLabel: 'Upload દિવ્ય અસ્ત્રો',
  ),
];

/// -----------------------------------------------------------------------
/// STABLE ID GENERATOR
/// -----------------------------------------------------------------------
/// The JSON only has Gujarati titles (e.g. "વાલ્મીકિ", "હનુમાન"), not
/// pre-made English ids. Hand-mapping ~130 titles by hand would be slow and
/// error-prone, and Firestore auto-IDs are explicitly not wanted (they'd be
/// random and would duplicate on re-upload). Instead this does a small,
/// deterministic Gujarati -> Latin transliteration, so the SAME title
/// always produces the SAME id (e.g. વાલ્મીકિ -> "valmiki",
/// હનુમાન -> "hanuman", સુગ્રીવ -> "sugriv"). It's an approximation, not a
/// linguist-grade romanization, but it is stable, readable, and collision-
/// checked (see _uploadCategory below).
class GujaratiSlugifier {
  static const Map<String, String> _consonants = {
    'ક': 'k', 'ખ': 'kh', 'ગ': 'g', 'ઘ': 'gh', 'ઙ': 'ng',
    'ચ': 'ch', 'છ': 'chh', 'જ': 'j', 'ઝ': 'jh', 'ઞ': 'ny',
    'ટ': 't', 'ઠ': 'th', 'ડ': 'd', 'ઢ': 'dh', 'ણ': 'n',
    'ત': 't', 'થ': 'th', 'દ': 'd', 'ધ': 'dh', 'ન': 'n',
    'પ': 'p', 'ફ': 'ph', 'બ': 'b', 'ભ': 'bh', 'મ': 'm',
    'ય': 'y', 'ર': 'r', 'લ': 'l', 'વ': 'v',
    'શ': 'sh', 'ષ': 'sh', 'સ': 's', 'હ': 'h', 'ળ': 'l',
  };

  static const Map<String, String> _independentVowels = {
    'અ': 'a', 'આ': 'a', 'ઇ': 'i', 'ઈ': 'i', 'ઉ': 'u', 'ઊ': 'u',
    'ઋ': 'ri', 'એ': 'e', 'ઐ': 'ai', 'ઓ': 'o', 'ઔ': 'au',
  };

  static const Map<String, String> _matras = {
    'ા': 'a', 'િ': 'i', 'ી': 'i', 'ુ': 'u', 'ૂ': 'u',
    'ૃ': 'ri', 'ે': 'e', 'ૈ': 'ai', 'ો': 'o', 'ૌ': 'au',
  };

  static const Map<String, String> _digits = {
    '૦': '0', '૧': '1', '૨': '2', '૩': '3', '૪': '4',
    '૫': '5', '૬': '6', '૭': '7', '૮': '8', '૯': '9',
  };

  static const String _virama = '્';
  static const String _anusvara = 'ં';
  static const String _visarga = 'ઃ';
  static const String _nukta = '઼';
  static const String _avagraha = 'ઽ';

  static String _transliterate(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      final next = (i + 1 < text.length) ? text[i + 1] : null;

      if (_consonants.containsKey(ch)) {
        buffer.write(_consonants[ch]);
        if (next == _virama) {
          i++; // halant: suppress inherent vowel, consume the mark
        } else if (next != null && _matras.containsKey(next)) {
          buffer.write(_matras[next]);
          i++; // consume the vowel sign
        } else if (next == null || next == ' ') {
          // word-final bare consonant: drop the default inherent vowel
          // (matches how these words are actually pronounced/spelled,
          // e.g. નારદ -> "narad" not "narada")
        } else {
          buffer.write('a'); // default inherent vowel
        }
      } else if (_independentVowels.containsKey(ch)) {
        buffer.write(_independentVowels[ch]);
      } else if (_digits.containsKey(ch)) {
        buffer.write(_digits[ch]);
      } else if (ch == _anusvara) {
        buffer.write('n');
      } else if (ch == _visarga) {
        buffer.write('h');
      } else if (ch == _nukta || ch == _avagraha) {
        // no direct roman equivalent used here; skip
      } else if (ch == ' ') {
        buffer.write('_');
      } else if (RegExp(r'[a-zA-Z0-9]').hasMatch(ch)) {
        buffer.write(ch.toLowerCase());
      }
      // any other punctuation/symbol is dropped
    }
    return buffer.toString();
  }

  /// Returns a stable slug for [text]; falls back to `item_<fallbackIndex>`
  /// if transliteration produces nothing usable.
  static String slugify(String text, int fallbackIndex) {
    var slug = _transliterate(text);
    slug = slug.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    slug = slug.replaceAll(RegExp(r'_+'), '_');
    slug = slug.replaceAll(RegExp(r'^_|_$'), '');
    if (slug.isEmpty) {
      slug = 'item_$fallbackIndex';
    }
    return slug;
  }
}

/// -----------------------------------------------------------------------
/// UI + UPLOAD LOGIC
/// -----------------------------------------------------------------------
class UploadHomePage extends StatefulWidget {
  const UploadHomePage({super.key});

  @override
  State<UploadHomePage> createState() => _UploadHomePageState();
}

class _UploadHomePageState extends State<UploadHomePage> {
  /// firestoreId of the category currently uploading, or null if idle.
  String? _uploadingCategoryId;

  Map<String, dynamic>? _cachedJson;

  Future<Map<String, dynamic>> _loadJson() async {
    if (_cachedJson != null) return _cachedJson!;
    final jsonString =
    await rootBundle.loadString('assets/main_data.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    _cachedJson = decoded;
    return decoded;
  }

  Future<void> _uploadCategory(CategoryConfig config) async {
    setState(() => _uploadingCategoryId = config.firestoreId);

    try {
      final data = await _loadJson();

      final rawTitles = data[config.jsonListKey];
      if (rawTitles is! List) {
        throw Exception(
          'Category key "${config.jsonListKey}" was not found in the JSON, '
              'or it is not a list of titles.',
        );
      }

      final firestore = FirebaseFirestore.instance;
      final itemsCollection = firestore
          .collection('RamayanaData')
          .doc('gu')
          .collection(config.firestoreId);

      // Build (docId, data) pairs first so every id is guaranteed unique
      // and stable before any network write happens.
      final usedIds = <String>{};
      final docsToWrite = <MapEntry<String, Map<String, dynamic>>>[];

      for (int i = 0; i < rawTitles.length; i++) {
        final title = rawTitles[i].toString();
        final detailKey = '${config.jsonListKey}_${i + 1}';
        final description = data[detailKey]?.toString() ?? '';

        final baseId = GujaratiSlugifier.slugify(title, i + 1);
        var uniqueId = baseId;
        var suffix = 2;
        while (usedIds.contains(uniqueId)) {
          uniqueId = '${baseId}_$suffix';
          suffix++;
        }
        usedIds.add(uniqueId);

        docsToWrite.add(
          MapEntry(uniqueId, {
            'id': uniqueId,
            'title': title,
            'description': description,
            'language': 'gu',
            'category': config.firestoreId,
          }),
        );
      }

      // Firestore allows up to 500 writes per batch; 400 leaves headroom.
      const batchSize = 400;
      var uploadedCount = 0;

      for (var start = 0; start < docsToWrite.length; start += batchSize) {
        final end = (start + batchSize < docsToWrite.length)
            ? start + batchSize
            : docsToWrite.length;

        final batch = firestore.batch();
        for (var j = start; j < end; j++) {
          final entry = docsToWrite[j];
          batch.set(itemsCollection.doc(entry.key), entry.value);
        }
        await batch.commit();
        uploadedCount += (end - start);
      }

      if (!mounted) return;
      setState(() => _uploadingCategoryId = null);
      _showMessage(
        'Upload completed successfully.\nDocuments uploaded: $uploadedCount',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingCategoryId = null);
      _showMessage('Upload failed:\n$e', isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valmiki Ramayan - Firebase Data Upload'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final config = kCategories[index];
          final isUploading = _uploadingCategoryId == config.firestoreId;
          final isAnyUploadInProgress = _uploadingCategoryId != null;

          return SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed:
              isAnyUploadInProgress ? null : () => _uploadCategory(config),
              child: isUploading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
                  : Text(config.buttonLabel),
            ),
          );
        },
      ),
    );
  }
}