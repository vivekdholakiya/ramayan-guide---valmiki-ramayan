import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ramayan_item.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Family parameter record for category fetching
class CategoryQueryParam {
  final String language;
  final String categoryId;

  const CategoryQueryParam({
    required this.language,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryQueryParam &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          categoryId == other.categoryId;

  @override
  int get hashCode => language.hashCode ^ categoryId.hashCode;
}

/// CategoryItemsFamily fetches items from Firestore for specific language & category
final categoryItemsProvider = FutureProvider.family
    .autoDispose<List<RamayanItem>, CategoryQueryParam>((ref, param) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getCategoryItems(
    param.language,
    param.categoryId,
  );
});

/// Search query string state for active category view
final categorySearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Filtered items based on local in-memory instant search query
final filteredCategoryItemsProvider = Provider.family
    .autoDispose<AsyncValue<List<RamayanItem>>, CategoryQueryParam>((ref, param) {
  final asyncItems = ref.watch(categoryItemsProvider(param));
  final query = ref.watch(categorySearchQueryProvider).trim().toLowerCase();

  return asyncItems.whenData((items) {
    if (query.isEmpty) return items;

    return items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query);
      final descMatch = item.description.toLowerCase().contains(query);
      return titleMatch || descMatch;
    }).toList();
  });
});
