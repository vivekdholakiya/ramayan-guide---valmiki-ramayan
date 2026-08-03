import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be overridden in ProviderScope');
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  final LocalStorageService _storage;

  LanguageNotifier(this._storage)
      : super(AppLanguage.fromCode(_storage.language));

  bool get hasSelectedLanguage => _storage.hasSelectedLanguage;

  Future<void> setLanguage(AppLanguage language) async {
    await _storage.setLanguage(language.code);
    state = language;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LanguageNotifier(storage);
});
