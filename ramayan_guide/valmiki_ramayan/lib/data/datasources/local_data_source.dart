import 'dart:io';
import '../../models/ramayan_item.dart';
import '../../models/status_category.dart';
import '../../models/status_quote.dart';
import '../../services/hive_storage_service.dart';
import '../../services/local_image_manager.dart';

/// LocalDataSource abstraction layer for reading/writing local Hive boxes and disk files.
class LocalDataSource {
  final HiveStorageService _hiveStorage;
  final LocalImageManager _imageManager;

  LocalDataSource({
    required HiveStorageService hiveStorage,
    required LocalImageManager imageManager,
  })  : _hiveStorage = hiveStorage,
        _imageManager = imageManager;

  // ── Categories ────────────────────────────────────────────────────────────
  List<StatusCategory>? getCategories(String language) {
    final raw = _hiveStorage.getCategories(language);
    if (raw == null) return null;
    return raw.map((json) => StatusCategory.fromJson(json)).toList();
  }

  Future<void> saveCategories(
      String language, List<StatusCategory> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    await _hiveStorage.saveCategories(language, jsonList);
  }

  // ── Quotes ────────────────────────────────────────────────────────────────
  List<StatusQuote>? getQuotes(String language, {String? categoryId}) {
    final key = categoryId ?? 'all';
    final raw = _hiveStorage.getQuotes(language, key);
    if (raw == null) return null;
    return raw.map((json) => StatusQuote.fromJson(json)).toList();
  }

  Future<void> saveQuotes(String language, String? categoryId,
      List<StatusQuote> quotes) async {
    final key = categoryId ?? 'all';
    final jsonList = quotes.map((q) => q.toJson()).toList();
    await _hiveStorage.saveQuotes(language, key, jsonList);
  }

  // ── Ramayan Content Items ──────────────────────────────────────────────────
  List<RamayanItem>? getRamayanItems(String language, String categoryId) {
    final raw = _hiveStorage.getRamayanItems(language, categoryId);
    if (raw == null) return null;
    return raw.map((json) => RamayanItem.fromJson(json)).toList();
  }

  Future<void> saveRamayanItems(
      String language, String categoryId, List<RamayanItem> items) async {
    final jsonList = items.map((i) => i.toJson()).toList();
    await _hiveStorage.saveRamayanItems(language, categoryId, jsonList);
  }

  // ── Image URLs & Local Files ──────────────────────────────────────────────
  List<String>? getImageUrls() {
    return _hiveStorage.getImageUrls();
  }

  Future<void> saveImageUrls(List<String> urls) async {
    await _hiveStorage.saveImageUrls(urls);
  }

  Future<File?> getLocalImageFile(String url) async {
    return await _imageManager.getLocalFile(url);
  }

  Future<String?> getOrDownloadImagePath(String url) async {
    return await _imageManager.getOrDownloadLocalPath(url);
  }

  Future<void> syncImageUrls(List<String> urls) async {
    await _imageManager.syncImageUrls(urls);
  }

  // ── Sync Timestamps ────────────────────────────────────────────────────────
  int? getLastSyncTime(String key) => _hiveStorage.getLastSyncTime(key);
  Future<void> setLastSyncTime(String key, int timestamp) =>
      _hiveStorage.setLastSyncTime(key, timestamp);
}
