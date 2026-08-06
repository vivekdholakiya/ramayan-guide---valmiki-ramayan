import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// HiveStorageService manages structured local caching using Hive boxes.
///
/// Storage Boxes:
///  - categories_box   : StatusCategory list per language
///  - quotes_box       : StatusQuote list per language/category
///  - items_box        : RamayanItem list per language/category
///  - image_cache_box  : Mapping of remote imageUrl -> localFilePath
///  - sync_meta_box    : Last sync timestamps
class HiveStorageService {
  static const String boxCategories = 'categories_box';
  static const String boxQuotes = 'quotes_box';
  static const String boxItems = 'items_box';
  static const String boxImageCache = 'image_cache_box';
  static const String boxSyncMeta = 'sync_meta_box';

  static Future<HiveStorageService> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(boxCategories),
      Hive.openBox<dynamic>(boxQuotes),
      Hive.openBox<dynamic>(boxItems),
      Hive.openBox<dynamic>(boxImageCache),
      Hive.openBox<dynamic>(boxSyncMeta),
    ]);
    return HiveStorageService();
  }

  Box<dynamic> _getBox(String name) => Hive.box<dynamic>(name);

  // ── Categories ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>>? getCategories(String language) {
    try {
      final data = _getBox(boxCategories).get(language);
      if (data is List) {
        return data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error reading categories: $e');
    }
    return null;
  }

  Future<void> saveCategories(
      String language, List<Map<String, dynamic>> categories) async {
    try {
      await _getBox(boxCategories).put(language, categories);
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error saving categories: $e');
    }
  }

  // ── Quotes ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>>? getQuotes(String language, String categoryId) {
    try {
      final key = '${language}_$categoryId';
      final data = _getBox(boxQuotes).get(key);
      if (data is List) {
        return data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error reading quotes: $e');
    }
    return null;
  }

  Future<void> saveQuotes(String language, String categoryId,
      List<Map<String, dynamic>> quotes) async {
    try {
      final key = '${language}_$categoryId';
      await _getBox(boxQuotes).put(key, quotes);
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error saving quotes: $e');
    }
  }

  // ── Ramayan Content Items ──────────────────────────────────────────────────
  List<Map<String, dynamic>>? getRamayanItems(
      String language, String categoryId) {
    try {
      final key = '${language}_$categoryId';
      final data = _getBox(boxItems).get(key);
      if (data is List) {
        return data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error reading items: $e');
    }
    return null;
  }

  Future<void> saveRamayanItems(String language, String categoryId,
      List<Map<String, dynamic>> items) async {
    try {
      final key = '${language}_$categoryId';
      await _getBox(boxItems).put(key, items);
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error saving items: $e');
    }
  }

  // ── Image Cache Metadata (Url -> Local Path) ──────────────────────────────
  String? getLocalImagePath(String url) {
    try {
      return _getBox(boxImageCache).get(url)?.toString();
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error reading image path: $e');
    }
    return null;
  }

  Future<void> saveLocalImagePath(String url, String localPath) async {
    try {
      await _getBox(boxImageCache).put(url, localPath);
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error saving image path: $e');
    }
  }

  Future<void> removeLocalImagePath(String url) async {
    try {
      await _getBox(boxImageCache).delete(url);
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error removing image path: $e');
    }
  }

  List<String>? getImageUrls() {
    try {
      final data = _getBox(boxImageCache).get('__all_image_urls__');
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error reading image URLs: $e');
    }
    return null;
  }

  Future<void> saveImageUrls(List<String> urls) async {
    try {
      await _getBox(boxImageCache).put('__all_image_urls__', urls);
    } catch (e) {
      if (kDebugMode) print('[HiveStorage] Error saving image URLs: $e');
    }
  }

  // ── Sync Timestamps ────────────────────────────────────────────────────────
  int? getLastSyncTime(String key) {
    try {
      return _getBox(boxSyncMeta).get(key) as int?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastSyncTime(String key, int timestamp) async {
    try {
      await _getBox(boxSyncMeta).put(key, timestamp);
    } catch (_) {}
  }
}
