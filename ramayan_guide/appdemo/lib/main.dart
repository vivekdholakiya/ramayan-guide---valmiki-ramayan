import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';

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
    await rootBundle.loadString('assets/main_data_en.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    _cachedJson = decoded;
    return decoded;
  }


  // Future<String> translateText(String text, {String to = 'hi'}) async {
  //   if (text.trim().isEmpty) return text;
  //
  //   final translator = GoogleTranslator();
  //
  //   try {
  //     final result = await translator.translate(
  //       text,
  //       from: 'gu',
  //       to: to,
  //     );
  //
  //     // Important: wait a bit to avoid rate limit
  //     await Future.delayed(const Duration(milliseconds: 800));
  //
  //     print(result.text);
  //     return result.text;
  //   } catch (e) {
  //     print('Translation failed for: $text → $e');
  //     return text; // fallback to original text
  //   }
  // }

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
          .doc('en')
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

        // final translatedTitle = await translateText(title);
        // final translatedDes = await translateText(description);

        docsToWrite.add(
          MapEntry(uniqueId, {
            'id': uniqueId,
            'title': title,
            'description': description,
            'language': 'en',
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
      print(e);
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

//
//
//
// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:translator/translator.dart';
//
// import 'firebase_options.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   runApp(const RamayanUploadApp());
// }
//
// class RamayanUploadApp extends StatelessWidget {
//   const RamayanUploadApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ramayan Quotes Firebase Upload',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: Colors.deepOrange,
//       ),
//       home: const UploadHomePage(),
//     );
//   }
// }
//
// class UploadHomePage extends StatefulWidget {
//   const UploadHomePage({super.key});
//
//   @override
//   State<UploadHomePage> createState() => _UploadHomePageState();
// }
//
// class _UploadHomePageState extends State<UploadHomePage> {
//   Map<String, dynamic>? _cachedJson;
//
//   bool _isUploading = false;
//   bool _isDeleting = false;
//
//   // ------------------------------------------------------------
//   // LOAD JSON FROM ASSETS
//   // ------------------------------------------------------------
//
//   Future<Map<String, dynamic>> _loadJson() async {
//     // If already loaded, don't load again.
//     if (_cachedJson != null) {
//       return _cachedJson!;
//     }
//
//     // Load JSON from Flutter assets.
//     final jsonString = await rootBundle.loadString(
//       'assets/ramayanamqt.json',
//     );
//
//     final decoded = jsonDecode(jsonString);
//
//     if (decoded is! Map<String, dynamic>) {
//       throw Exception(
//         'ramayanamqt.json must contain a JSON object.',
//       );
//     }
//
//     _cachedJson = decoded;
//
//     return decoded;
//   }
//
//   // ------------------------------------------------------------
//   // UPLOAD ALL DATA
//   // ------------------------------------------------------------
//
//   Future<void> _uploadAllData() async {
//     if (_isUploading || _isDeleting) {
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//     });
//
//     try {
//       // ----------------------------------------------------------
//       // 1. LOAD JSON
//       // ----------------------------------------------------------
//
//       final data = await _loadJson();
//
//       // ----------------------------------------------------------
//       // 2. GET CATEGORIES
//       // ----------------------------------------------------------
//
//       final rawCategories = data['categories'];
//
//       if (rawCategories is! List) {
//         throw Exception(
//           '"categories" not found or is not a List.',
//         );
//       }
//
//       // ----------------------------------------------------------
//       // 3. GET QUOTES
//       // ----------------------------------------------------------
//
//       final rawQuotes = data['quotes'];
//
//       if (rawQuotes is! List) {
//         throw Exception(
//           '"quotes" not found or is not a List.',
//         );
//       }
//
//       // ----------------------------------------------------------
//       // FIREBASE
//       // ----------------------------------------------------------
//
//       final firestore = FirebaseFirestore.instance;
//
//       final languageDocument = firestore
//           .collection('RamayanQuotes')
//           .doc('en');
//
//       // ==========================================================
//       // UPLOAD CATEGORIES
//       // ==========================================================
//
//       final categoriesCollection =
//       languageDocument.collection('categories');
//
//       final Map<String, String> categoryIdMap = {};
//
//       int categoryCount = 0;
//
//       for (int i = 0; i < rawCategories.length; i++) {
//         final categoryName = rawCategories[i]
//             .toString()
//             .trim();
//
//         if (categoryName.isEmpty) {
//           continue;
//         }
//
//         final categoryId = _createCategoryId(
//           categoryName,
//           i + 1,
//         );
//
//         // Save category name -> category ID
//         categoryIdMap[categoryName] = categoryId;
//         final translatedName = await translateText(categoryName);
//         await categoriesCollection
//             .doc(categoryId)
//             .set({
//           'id': categoryId,
//           'name': translatedName,//
//           'language': 'en',
//         });
//
//         categoryCount++;
//       }
//
//       // ==========================================================
//       // UPLOAD QUOTES
//       // ==========================================================
//
//       final quotesCollection = languageDocument.collection('quotes');
//
//       final Set<String> usedQuoteIds = {};
//
//       const int batchSize = 400;
//
//       int uploadedQuotes = 0;
//
//       WriteBatch batch = firestore.batch();
//
//       int batchCount = 0;
//
//       for (int i = 0; i < rawQuotes.length; i++) {
//         final rawQuote = rawQuotes[i];
//
//         if (rawQuote is! Map) {
//           throw Exception(
//             'Quote at index $i is not a valid object.',
//           );
//         }
//
//         // --------------------------------------------------------
//         // GET VALUES
//         // --------------------------------------------------------
//
//         final quoteId = rawQuote['id']?.toString().trim() ?? '';
//
//         final category =
//             rawQuote['category']?.toString().trim() ?? '';
//
//         final text = rawQuote['text']?.toString().trim() ?? '';
//
//         // --------------------------------------------------------
//         // VALIDATION
//         // --------------------------------------------------------
//
//         if (quoteId.isEmpty) {
//           throw Exception(
//             'Quote at index $i does not have an "id".',
//           );
//         }
//
//         if (category.isEmpty) {
//           throw Exception(
//             'Quote "$quoteId" does not have a category.',
//           );
//         }
//
//         if (text.isEmpty) {
//           throw Exception(
//             'Quote "$quoteId" does not have text.',
//           );
//         }
//
//         if (usedQuoteIds.contains(quoteId)) {
//           throw Exception(
//             'Duplicate quote ID found: $quoteId',
//           );
//         }
//
//         usedQuoteIds.add(quoteId);
//
//         // --------------------------------------------------------
//         // FIND CATEGORY ID
//         // --------------------------------------------------------
//
//         final categoryId = categoryIdMap[category];
//
//         if (categoryId == null) {
//           throw Exception(
//             'Category "$category" does not exist '
//                 'in the categories list.',
//           );
//         }
//
//         // --------------------------------------------------------
//         // FIRESTORE DOCUMENT
//         // --------------------------------------------------------
//
//         final quoteDocument =
//         quotesCollection.doc(quoteId);
//         final translatedText = await translateText(text);
//         final translatedName = await translateText(category);
//
//         batch.set(
//           quoteDocument,
//           {
//             'id': quoteId,
//             'category': translatedName,
//             'categoryId': categoryId,
//             'text': translatedText,
//             'language': 'en',
//           },
//         );
//
//         batchCount++;
//         uploadedQuotes++;
//
//         // --------------------------------------------------------
//         // COMMIT EVERY 400 DOCUMENTS
//         // --------------------------------------------------------
//
//         if (batchCount == batchSize) {
//           await batch.commit();
//
//           batch = firestore.batch();
//           batchCount = 0;
//         }
//       }
//
//       // ------------------------------------------------------------
//       // COMMIT REMAINING DOCUMENTS
//       // ------------------------------------------------------------
//
//       if (batchCount > 0) {
//         await batch.commit();
//       }
//
//       if (!mounted) {
//         return;
//       }
//
//       setState(() {
//         _isUploading = false;
//       });
//
//       _showMessage(
//         'Upload completed successfully!\n\n'
//             'Categories: $categoryCount\n'
//             'Quotes: $uploadedQuotes',
//         isError: false,
//       );
//     } catch (e) {
//       if (!mounted) {
//         return;
//       }
//
//       setState(() {
//         _isUploading = false;
//       });
//
//       _showMessage(
//         'Upload failed:\n$e',
//         isError: true,
//       );
//       print(e);
//     }
//   }
//
//   Future<String> translateText(String text, {String to = 'en'}) async {
//     final translator = GoogleTranslator();
//     final result = await translator.translate(text, from: 'gu', to: to);
//     print( result.text);
//     return result.text;
//   }
//
//
//   // ------------------------------------------------------------
//   // CREATE CATEGORY ID
//   // ------------------------------------------------------------
//
//
//
//   String _createCategoryId(
//       String category,
//       int index,
//       ) {
//     const Map<String, String> map = {
//       'શ્રી રામ': 'shri_ram',
//       'ધર્મ': 'dharma',
//       'ભક્તિ': 'bhakti',
//       'જીવન': 'jivan',
//       'પ્રેરણા': 'prerna',
//       'સંબંધો': 'sambandho',
//     };
//
//     if (map.containsKey(category)) {
//       return map[category]!;
//     }
//
//     // Fallback ID if a new category is added.
//     return 'category_$index';
//   }
//
//   // ------------------------------------------------------------
//   // DELETE ALL DATA
//   // ------------------------------------------------------------
//
//   Future<void> _deleteAllData() async {
//     if (_isUploading || _isDeleting) {
//       return;
//     }
//
//     setState(() {
//       _isDeleting = true;
//     });
//
//     try {
//       final firestore = FirebaseFirestore.instance;
//
//       final languageDocument = firestore
//           .collection('RamayanQuotes')
//           .doc('gu');
//
//       // ----------------------------------------------------------
//       // GET CATEGORIES
//       // ----------------------------------------------------------
//
//       final categoriesSnapshot =
//       await languageDocument
//           .collection('categories')
//           .get();
//
//       // ----------------------------------------------------------
//       // GET QUOTES
//       // ----------------------------------------------------------
//
//       final quotesSnapshot =
//       await languageDocument
//           .collection('quotes')
//           .get();
//
//       // ----------------------------------------------------------
//       // DELETE IN BATCHES
//       // ----------------------------------------------------------
//
//       final allDocuments = [
//         ...categoriesSnapshot.docs,
//         ...quotesSnapshot.docs,
//       ];
//
//       const int batchSize = 400;
//
//       for (
//       int start = 0;
//       start < allDocuments.length;
//       start += batchSize
//       ) {
//         final end =
//         (start + batchSize < allDocuments.length)
//             ? start + batchSize
//             : allDocuments.length;
//
//         final batch = firestore.batch();
//
//         for (int i = start; i < end; i++) {
//           batch.delete(
//             allDocuments[i].reference,
//           );
//         }
//
//         await batch.commit();
//       }
//
//       if (!mounted) {
//         return;
//       }
//
//       setState(() {
//         _isDeleting = false;
//       });
//
//       _showMessage(
//         'All Firebase data deleted successfully.',
//         isError: false,
//       );
//     } catch (e) {
//       if (!mounted) {
//         return;
//       }
//
//       setState(() {
//         _isDeleting = false;
//       });
//
//       _showMessage(
//         'Delete failed:\n$e',
//         isError: true,
//       );
//     }
//   }
//
//   // ------------------------------------------------------------
//   // SHOW MESSAGE
//   // ------------------------------------------------------------
//
//   void _showMessage(
//       String message, {
//         required bool isError,
//       }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor:
//         isError ? Colors.red : Colors.green.shade700,
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }
//
//   // ------------------------------------------------------------
//   // UI
//   // ------------------------------------------------------------
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isBusy =
//         _isUploading || _isDeleting;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Ramayan Quotes Firebase Upload',
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // --------------------------------------------------------
//           // INFO
//           // --------------------------------------------------------
//
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment:
//                 CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Gujarati Ramayan Quotes',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Data source: assets/ramayanamqt.json',
//                     style: TextStyle(
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // --------------------------------------------------------
//           // UPLOAD BUTTON
//           // --------------------------------------------------------
//
//           SizedBox(
//             height: 55,
//             child: ElevatedButton.icon(
//               onPressed:
//               isBusy ? null : _uploadAllData,
//               icon: _isUploading
//                   ? const SizedBox(
//                 width: 22,
//                 height: 22,
//                 child:
//                 CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                 ),
//               )
//                   : const Icon(
//                 Icons.cloud_upload,
//               ),
//               label: Text(
//                 _isUploading
//                     ? 'Uploading...'
//                     : 'Upload All Data',
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 15),
//
//           // --------------------------------------------------------
//           // DELETE BUTTON
//           // --------------------------------------------------------
//
//           SizedBox(
//             height: 55,
//             child: OutlinedButton.icon(
//               onPressed:
//               isBusy ? null : _deleteAllData,
//               icon: _isDeleting
//                   ? const SizedBox(
//                 width: 22,
//                 height: 22,
//                 child:
//                 CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                 ),
//               )
//                   : const Icon(
//                 Icons.delete_outline,
//               ),
//               label: Text(
//                 _isDeleting
//                     ? 'Deleting...'
//                     : 'Delete All Firebase Data',
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 30),
//
//           // --------------------------------------------------------
//           // FIREBASE STRUCTURE
//           // --------------------------------------------------------
//
//           const Text(
//             'Firebase Structure',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//           const SizedBox(height: 10),
//
//           Container(
//             padding: const EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius:
//               BorderRadius.circular(12),
//             ),
//             child: const Text(
//               '''
// RamayanQuotes
// └── gu
//     ├── categories
//     │   ├── shri_ram
//     │   ├── dharma
//     │   ├── bhakti
//     │   ├── jivan
//     │   ├── prerna
//     │   └── sambandho
//     │
//     └── quotes
//         ├── quote_001
//         ├── quote_002
//         ├── quote_003
//         └── ...
// ''',
//               style: TextStyle(
//                 fontFamily: 'monospace',
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }