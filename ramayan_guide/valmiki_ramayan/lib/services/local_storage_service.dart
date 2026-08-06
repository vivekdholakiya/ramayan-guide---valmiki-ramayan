import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ramayan_item.dart';

/// LocalStorageService persists user preferences, favorites, history,
/// and reading state locally using SharedPreferences.
class LocalStorageService {
  static const String _keyLanguage = 'selected_language';
  static const String _keyTheme = 'selected_theme';
  static const String _keyFontSize = 'selected_font_size';
  static const String _keyFavorites = 'user_favorites_v1';
  static const String _keyRecent = 'recently_viewed_v1';
  static const String _keyContinueReading = 'continue_reading_v1';
  static const String _keyLanguageSelected = 'has_selected_language';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // --- First Launch & Language ---
  bool get hasSelectedLanguage => _prefs.getBool(_keyLanguageSelected) ?? false;

  Future<void> setHasSelectedLanguage(bool value) async {
    await _prefs.setBool(_keyLanguageSelected, value);
  }

  String get language => _prefs.getString(_keyLanguage) ?? 'gu';

  Future<void> setLanguage(String code) async {
    await _prefs.setString(_keyLanguage, code);
    await setHasSelectedLanguage(true);
  }

  // --- Theme ---
  String get themeKey => _prefs.getString(_keyTheme) ?? 'system';

  Future<void> setThemeKey(String key) async {
    await _prefs.setString(_keyTheme, key);
  }

  // --- Font Size ---
  String get fontSizeKey => _prefs.getString(_keyFontSize) ?? 'medium';

  Future<void> setFontSizeKey(String key) async {
    await _prefs.setString(_keyFontSize, key);
  }

  // --- Favorites ---
  List<RamayanItem> getFavorites() {
    final list = _prefs.getStringList(_keyFavorites) ?? [];
    return list.map((jsonStr) {
      try {
        return RamayanItem.fromJson(json.decode(jsonStr));
      } catch (_) {
        return null;
      }
    }).whereType<RamayanItem>().toList();
  }

  Future<void> saveFavorites(List<RamayanItem> favorites) async {
    final list = favorites.map((item) => json.encode(item.toJson())).toList();
    await _prefs.setStringList(_keyFavorites, list);
  }

  bool isFavorite(String itemId, String categoryId) {
    final favorites = getFavorites();
    return favorites.any((item) => item.id == itemId && item.category == categoryId);
  }

  Future<void> toggleFavorite(RamayanItem item) async {
    final favorites = getFavorites();
    final index = favorites.indexWhere(
        (e) => e.id == item.id && e.category == item.category);
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.insert(0, item);
    }
    await saveFavorites(favorites);
  }

  // --- Recently Viewed ---
  List<RamayanItem> getRecentlyViewed() {
    final list = _prefs.getStringList(_keyRecent) ?? [];
    return list.map((jsonStr) {
      try {
        return RamayanItem.fromJson(json.decode(jsonStr));
      } catch (_) {
        return null;
      }
    }).whereType<RamayanItem>().toList();
  }

  Future<void> addRecentlyViewed(RamayanItem item) async {
    final list = getRecentlyViewed();
    list.removeWhere((e) => e.id == item.id && e.category == item.category);
    list.insert(0, item);
    if (list.length > 15) {
      list.removeLast();
    }
    final encoded = list.map((i) => json.encode(i.toJson())).toList();
    await _prefs.setStringList(_keyRecent, encoded);
  }

  // --- Continue Reading ---
  RamayanItem? getContinueReading() {
    final str = _prefs.getString(_keyContinueReading);
    if (str == null) return null;
    try {
      return RamayanItem.fromJson(json.decode(str));
    } catch (_) {
      return null;
    }
  }

  Future<void> setContinueReading(RamayanItem item) async {
    await _prefs.setString(_keyContinueReading, json.encode(item.toJson()));
  }

  // --- Clear Content Data on Language Change ---
  Future<void> clearUserContentData() async {
    await _prefs.remove(_keyFavorites);
    await _prefs.remove(_keyRecent);
    await _prefs.remove(_keyContinueReading);
  }
}
