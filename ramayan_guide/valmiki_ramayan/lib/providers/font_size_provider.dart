import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'language_provider.dart';

class FontSizeNotifier extends StateNotifier<AppFontSize> {
  final Ref _ref;

  FontSizeNotifier(this._ref)
      : super(AppFontSize.fromKey(
            _ref.read(localStorageServiceProvider).fontSizeKey));

  Future<void> setFontSize(AppFontSize fontSize) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.setFontSizeKey(fontSize.key);
    state = fontSize;
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, AppFontSize>((ref) {
  return FontSizeNotifier(ref);
});
