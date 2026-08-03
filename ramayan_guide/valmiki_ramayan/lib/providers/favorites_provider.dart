import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ramayan_item.dart';
import 'language_provider.dart';

class FavoritesNotifier extends StateNotifier<List<RamayanItem>> {
  final Ref _ref;

  FavoritesNotifier(this._ref)
      : super(_ref.read(localStorageServiceProvider).getFavorites());

  Future<void> toggleFavorite(RamayanItem item) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.toggleFavorite(item);
    state = storage.getFavorites();
  }

  bool isFavorite(String itemId, String categoryId) {
    return state.any((item) => item.id == itemId && item.category == categoryId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<RamayanItem>>((ref) {
  return FavoritesNotifier(ref);
});
