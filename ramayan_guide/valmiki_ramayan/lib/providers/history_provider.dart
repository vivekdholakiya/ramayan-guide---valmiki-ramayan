import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ramayan_item.dart';
import 'language_provider.dart';

class HistoryNotifier extends StateNotifier<List<RamayanItem>> {
  final Ref _ref;

  HistoryNotifier(this._ref)
      : super(_ref.read(localStorageServiceProvider).getRecentlyViewed());

  Future<void> recordView(RamayanItem item) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.addRecentlyViewed(item);
    await storage.setContinueReading(item);
    state = storage.getRecentlyViewed();
    _ref.read(continueReadingProvider.notifier).refresh();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<RamayanItem>>((ref) {
  return HistoryNotifier(ref);
});

class ContinueReadingNotifier extends StateNotifier<RamayanItem?> {
  final Ref _ref;

  ContinueReadingNotifier(this._ref)
      : super(_ref.read(localStorageServiceProvider).getContinueReading());

  void refresh() {
    state = _ref.read(localStorageServiceProvider).getContinueReading();
  }
}

final continueReadingProvider =
    StateNotifierProvider<ContinueReadingNotifier, RamayanItem?>((ref) {
  return ContinueReadingNotifier(ref);
});
