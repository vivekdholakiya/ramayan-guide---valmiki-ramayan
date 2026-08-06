import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/ramayan_item.dart';
import '../../models/status_category.dart';
import '../../models/status_quote.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

/// RamayanRepository coordinates offline-first data fetching and silent
/// background synchronization between local Hive storage and remote Firebase.
///
/// Pattern:
///  Local Storage -> Return data immediately to UI
///  ↓
///  Background Firebase Sync
///  ↓
///  Update Local Database & Download Missing Images
///  ↓
///  Update UI automatically if data changed
class RamayanRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  // Stream controllers to broadcast background updates to UI
  final _categoriesController =
      StreamController<Map<String, List<StatusCategory>>>.broadcast();
  final _quotesController =
      StreamController<Map<String, List<StatusQuote>>>.broadcast();
  final _itemsController =
      StreamController<Map<String, List<RamayanItem>>>.broadcast();

  RamayanRepository({
    required LocalDataSource localDataSource,
    required RemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  Stream<List<StatusCategory>> watchCategories(String language) {
    return _categoriesController.stream
        .where((map) => map.containsKey(language))
        .map((map) => map[language]!);
  }

  Stream<List<StatusQuote>> watchQuotes(String language, String? categoryId) {
    final key = '${language}_${categoryId ?? 'all'}';
    return _quotesController.stream
        .where((map) => map.containsKey(key))
        .map((map) => map[key]!);
  }

  Stream<List<RamayanItem>> watchRamayanItems(
      String language, String categoryId) {
    final key = '${language}_$categoryId';
    return _itemsController.stream
        .where((map) => map.containsKey(key))
        .map((map) => map[key]!);
  }

  // ── 1. Categories (Offline First) ──────────────────────────────────────────
  Future<List<StatusCategory>> getCategories(
    String language, {
    bool forceSync = false,
  }) async {
    final localCategories = _localDataSource.getCategories(language);

    if (localCategories != null && localCategories.isNotEmpty && !forceSync) {
      _syncCategoriesInBackground(language);
      return localCategories;
    }

    try {
      final remoteCategories =
          await _remoteDataSource.fetchCategories(language);
      if (remoteCategories.isNotEmpty) {
        await _localDataSource.saveCategories(language, remoteCategories);
        return remoteCategories;
      }
    } catch (e) {
      if (kDebugMode) print('[Repository] Remote categories fetch failed: $e');
    }

    return localCategories ?? [];
  }

  void _syncCategoriesInBackground(String language) {
    unawaited(() async {
      try {
        final remoteCategories =
            await _remoteDataSource.fetchCategories(language);
        if (remoteCategories.isNotEmpty) {
          final local = _localDataSource.getCategories(language);
          if (!_areCategoriesEqual(local, remoteCategories)) {
            await _localDataSource.saveCategories(language, remoteCategories);
            _categoriesController.add({language: remoteCategories});
            if (kDebugMode) {
              print('[Repository] Categories updated silently from remote.');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('[Repository] Background category sync error: $e');
      }
    }());
  }

  // ── 2. Quotes (Offline First) ──────────────────────────────────────────────
  Future<List<StatusQuote>> getQuotes(
    String language, {
    String? categoryId,
    bool forceSync = false,
  }) async {
    final localQuotes =
        _localDataSource.getQuotes(language, categoryId: categoryId);

    if (localQuotes != null && localQuotes.isNotEmpty && !forceSync) {
      _syncQuotesInBackground(language, categoryId);
      return localQuotes;
    }

    try {
      final remoteQuotes = await _remoteDataSource.fetchQuotes(language,
          categoryId: categoryId);
      if (remoteQuotes.isNotEmpty) {
        await _localDataSource.saveQuotes(language, categoryId, remoteQuotes);
        return remoteQuotes;
      }
    } catch (e) {
      if (kDebugMode) print('[Repository] Remote quotes fetch failed: $e');
    }

    return localQuotes ?? [];
  }

  void _syncQuotesInBackground(String language, String? categoryId) {
    unawaited(() async {
      try {
        final remoteQuotes = await _remoteDataSource.fetchQuotes(language,
            categoryId: categoryId);
        if (remoteQuotes.isNotEmpty) {
          final local =
              _localDataSource.getQuotes(language, categoryId: categoryId);
          if (!_areQuotesEqual(local, remoteQuotes)) {
            await _localDataSource.saveQuotes(
                language, categoryId, remoteQuotes);
            final key = '${language}_${categoryId ?? 'all'}';
            _quotesController.add({key: remoteQuotes});
            if (kDebugMode) {
              print(
                  '[Repository] Quotes ($key) updated silently from remote.');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('[Repository] Background quotes sync error: $e');
      }
    }());
  }

  // ── 3. Image URLs & Permanent Local Disk Image Caching ──────────────────────
  Future<List<String>> getImageUrls({bool forceSync = false}) async {
    final localUrls = _localDataSource.getImageUrls();

    if (localUrls != null && localUrls.isNotEmpty && !forceSync) {
      _syncImageUrlsInBackground();
      return localUrls;
    }

    try {
      final remoteUrls = await _remoteDataSource.fetchImageUrls();
      if (remoteUrls.isNotEmpty) {
        await _localDataSource.saveImageUrls(remoteUrls);
        // Permanently cache images on disk in background
        unawaited(_localDataSource.syncImageUrls(remoteUrls));
        return remoteUrls;
      }
    } catch (e) {
      if (kDebugMode) print('[Repository] Remote image URLs fetch failed: $e');
    }

    return localUrls ?? [];
  }

  void _syncImageUrlsInBackground() {
    unawaited(() async {
      try {
        final remoteUrls = await _remoteDataSource.fetchImageUrls();
        if (remoteUrls.isNotEmpty) {
          await _localDataSource.saveImageUrls(remoteUrls);
          await _localDataSource.syncImageUrls(remoteUrls);
        }
      } catch (e) {
        if (kDebugMode) print('[Repository] Background image sync error: $e');
      }
    }());
  }

  /// Helper to get local File for an image URL if stored on disk.
  Future<File?> getLocalImageFile(String url) async {
    return await _localDataSource.getLocalImageFile(url);
  }

  /// Helper returning local image file path if available, downloading if missing.
  Future<String?> getOrDownloadImagePath(String url) async {
    return await _localDataSource.getOrDownloadImagePath(url);
  }

  // ── 4. Ramayan Content Items (Offline First) ───────────────────────────────
  Future<List<RamayanItem>> getRamayanItems(
    String language,
    String categoryId, {
    bool forceSync = false,
  }) async {
    final localItems =
        _localDataSource.getRamayanItems(language, categoryId);

    if (localItems != null && localItems.isNotEmpty && !forceSync) {
      _syncRamayanItemsInBackground(language, categoryId);
      return localItems;
    }

    try {
      final remoteItems =
          await _remoteDataSource.fetchRamayanItems(language, categoryId);
      if (remoteItems.isNotEmpty) {
        await _localDataSource.saveRamayanItems(
            language, categoryId, remoteItems);
        return remoteItems;
      }
    } catch (e) {
      if (kDebugMode) print('[Repository] Remote items fetch failed: $e');
    }

    return localItems ?? [];
  }

  void _syncRamayanItemsInBackground(String language, String categoryId) {
    unawaited(() async {
      try {
        final remoteItems =
            await _remoteDataSource.fetchRamayanItems(language, categoryId);
        if (remoteItems.isNotEmpty) {
          final local = _localDataSource.getRamayanItems(language, categoryId);
          if (!_areItemsEqual(local, remoteItems)) {
            await _localDataSource.saveRamayanItems(
                language, categoryId, remoteItems);
            final key = '${language}_$categoryId';
            _itemsController.add({key: remoteItems});
            if (kDebugMode) {
              print(
                  '[Repository] Items ($key) updated silently from remote.');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('[Repository] Background items sync error: $e');
      }
    }());
  }

  // ── Equality comparison helpers ──────────────────────────────────────────
  bool _areCategoriesEqual(
      List<StatusCategory>? a, List<StatusCategory> b) {
    if (a == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].name != b[i].name) return false;
    }
    return true;
  }

  bool _areQuotesEqual(List<StatusQuote>? a, List<StatusQuote> b) {
    if (a == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].text != b[i].text) return false;
    }
    return true;
  }

  bool _areItemsEqual(List<RamayanItem>? a, List<RamayanItem> b) {
    if (a == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].title != b[i].title) return false;
    }
    return true;
  }

  void dispose() {
    _categoriesController.close();
    _quotesController.close();
    _itemsController.close();
  }
}
