import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/ramayan_item.dart';

/// FirestoreService provides read-only access to RamayanaData content
/// stored in Firebase Firestore at path: RamayanaData/{language}/{categoryId}.
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// In-memory cache to prevent duplicate network reads during session.
  /// Key format: "{language}_{categoryId}" e.g., "gu_rishio"
  final Map<String, List<RamayanItem>> _categoryCache = {};

  /// Synchronously clear session cache if needed (e.g. upon user pull-to-refresh).
  void clearCache([String? cacheKey]) {
    if (cacheKey != null) {
      _categoryCache.remove(cacheKey);
    } else {
      _categoryCache.clear();
    }
  }

  /// Fetches items for a specific category and language.
  /// Uses session in-memory cache if available.
  Future<List<RamayanItem>> getCategoryItems(
    String language,
    String categoryId, {
    bool forceRefresh = false,
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    final cacheKey = '${language}_$categoryId';

    // 1. Check in-memory cache first if not pagination or force refresh
    if (!forceRefresh &&
        lastDocument == null &&
        _categoryCache.containsKey(cacheKey)) {
      if (kDebugMode) {
        print('Returning cached items for key: $cacheKey');
      }
      return _categoryCache[cacheKey]!;
    }

    try {
      // 2. Query Firestore at exact path: RamayanaData/{language}/{categoryId}
      Query<Map<String, dynamic>> query = _firestore
          .collection('RamayanaData')
          .doc(language)
          .collection(categoryId);

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get(const GetOptions(
        source: Source.serverAndCache,
      ));

      final items = querySnapshot.docs.map((doc) {
        return RamayanItem.fromFirestore(
          doc,
          fallbackLanguage: language,
          fallbackCategory: categoryId,
        );
      }).toList();

      // Cache the result for initial fetch
      if (lastDocument == null && !forceRefresh) {
        _categoryCache[cacheKey] = items;
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Firestore collection: $cacheKey -> $e');
      }
      // If network fails, attempt cache-only source
      try {
        final querySnapshot = await _firestore
            .collection('RamayanaData')
            .doc(language)
            .collection(categoryId)
            .get(const GetOptions(source: Source.cache));

        return querySnapshot.docs.map((doc) {
          return RamayanItem.fromFirestore(
            doc,
            fallbackLanguage: language,
            fallbackCategory: categoryId,
          );
        }).toList();
      } catch (_) {
        rethrow;
      }
    }
  }

  /// Fetches a single item from Firestore: RamayanaData/{language}/{categoryId}/{itemId}
  Future<RamayanItem?> getItem(
    String language,
    String categoryId,
    String itemId,
  ) async {
    final cacheKey = '${language}_$categoryId';

    // Check in-memory cache first
    if (_categoryCache.containsKey(cacheKey)) {
      final cachedList = _categoryCache[cacheKey]!;
      final found = cachedList.where((item) => item.id == itemId);
      if (found.isNotEmpty) {
        return found.first;
      }
    }

    try {
      final docRef = _firestore
          .collection('RamayanaData')
          .doc(language)
          .collection(categoryId)
          .doc(itemId);

      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        return RamayanItem.fromFirestore(
          doc,
          fallbackLanguage: language,
          fallbackCategory: categoryId,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching item $itemId: $e');
      }
      return null;
    }
  }
}
