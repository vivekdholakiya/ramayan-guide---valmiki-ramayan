import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/status_category.dart';
import '../models/status_quote.dart';

/// StatusService reads devotional quote data from Firestore.
///
/// Paths:
///   Quotes     → /RamayanQuotes/{language}/quotes
///   Categories → /RamayanQuotes/{language}/categories
///   Images     → /RamayanQuotes/imageUrl  (single document, all fields = URLs)
///
/// Uses in-memory session cache identical to the existing FirestoreService pattern.
class StatusService {
  final FirebaseFirestore _firestore;

  StatusService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── In-memory caches ──────────────────────────────────────────────────────
  final Map<String, List<StatusCategory>> _categoryCache = {};
  final Map<String, List<StatusQuote>> _quotesCache = {};
  List<String>? _imageUrlsCache;

  void clearCache() {
    _categoryCache.clear();
    _quotesCache.clear();
    _imageUrlsCache = null;
  }

  // ── Categories ────────────────────────────────────────────────────────────

  /// Fetches all quote categories for the given language.
  Future<List<StatusCategory>> fetchCategories(
    String language, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _categoryCache.containsKey(language)) {
      return _categoryCache[language]!;
    }

    try {
      final snapshot = await _firestore
          .collection('RamayanQuotes')
          .doc(language)
          .collection('categories')
          .get(const GetOptions(source: Source.serverAndCache));

      final categories = snapshot.docs
          .map((doc) => StatusCategory.fromFirestore(doc))
          .toList();

      _categoryCache[language] = categories;
      return categories;
    } catch (e) {
      if (kDebugMode) print('[StatusService] fetchCategories error: $e');
      // Attempt offline cache
      try {
        final snapshot = await _firestore
            .collection('RamayanQuotes')
            .doc(language)
            .collection('categories')
            .get(const GetOptions(source: Source.cache));
        return snapshot.docs
            .map((doc) => StatusCategory.fromFirestore(doc))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  // ── Quotes ────────────────────────────────────────────────────────────────

  /// Fetches all quotes for the given language.
  /// If [categoryId] is provided, filters to that category.
  Future<List<StatusQuote>> fetchQuotes(
    String language, {
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${language}_${categoryId ?? 'all'}';

    if (!forceRefresh && _quotesCache.containsKey(cacheKey)) {
      return _quotesCache[cacheKey]!;
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('RamayanQuotes')
          .doc(language)
          .collection('quotes');

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final snapshot =
          await query.get(const GetOptions(source: Source.serverAndCache));

      final quotes = snapshot.docs
          .map((doc) => StatusQuote.fromFirestore(doc))
          .where((q) => q.isValid)
          .toList();

      _quotesCache[cacheKey] = quotes;
      return quotes;
    } catch (e) {
      if (kDebugMode) print('[StatusService] fetchQuotes error: $e');
      try {
        Query<Map<String, dynamic>> query = _firestore
            .collection('RamayanQuotes')
            .doc(language)
            .collection('quotes');

        if (categoryId != null && categoryId.isNotEmpty) {
          query = query.where('categoryId', isEqualTo: categoryId);
        }

        final snapshot =
            await query.get(const GetOptions(source: Source.cache));

        return snapshot.docs
            .map((doc) => StatusQuote.fromFirestore(doc))
            .where((q) => q.isValid)
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  // ── Image URLs ────────────────────────────────────────────────────────────

  /// Fetches all background image URLs from /RamayanQuotes/imageUrl document.
  ///
  /// IMPORTANT: All field values in that document are treated as image URLs,
  /// regardless of field name (img_1, img_2, img_100, etc.).
  /// New fields are automatically picked up without any code changes.
  Future<List<String>> fetchImageUrls({bool forceRefresh = false}) async {
    if (!forceRefresh && _imageUrlsCache != null) {
      return _imageUrlsCache!;
    }

    try {
      final doc = await _firestore
          .collection('RamayanQuotes')
          .doc('imageUrl')
          .get(const GetOptions(source: Source.serverAndCache));

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) print('[StatusService] imageUrl document not found');
        return [];
      }

      // Dynamically read ALL field values — works regardless of field count/names
      final urls = doc
          .data()!
          .values
          .map((v) => v?.toString().trim() ?? '')
          .where((url) => url.isNotEmpty && url.startsWith('http'))
          .toList();

      _imageUrlsCache = urls;
      if (kDebugMode) print('[StatusService] Loaded ${urls.length} image URLs');
      return urls;
    } catch (e) {
      if (kDebugMode) print('[StatusService] fetchImageUrls error: $e');
      try {
        final doc = await _firestore
            .collection('RamayanQuotes')
            .doc('imageUrl')
            .get(const GetOptions(source: Source.cache));

        if (!doc.exists || doc.data() == null) return [];

        return doc
            .data()!
            .values
            .map((v) => v?.toString().trim() ?? '')
            .where((url) => url.isNotEmpty && url.startsWith('http'))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }
}
