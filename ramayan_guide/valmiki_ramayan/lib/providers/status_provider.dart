import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/status_category.dart';
import '../models/status_item.dart';
import '../models/status_quote.dart';
import '../services/status_randomizer.dart';
import '../services/status_service.dart';
import 'offline_provider.dart';

// ── Service Providers ─────────────────────────────────────────────────────

final statusServiceProvider = Provider<StatusService>((ref) {
  return StatusService();
});

final statusRandomizerProvider = Provider<StatusRandomizer>((ref) {
  return StatusRandomizer();
});

// ── Data Fetching Providers (Offline-First via Repository) ────────────────

/// Fetches all quote categories for the given language (Local Hive -> Remote Sync).
final statusCategoriesProvider =
    FutureProvider.family<List<StatusCategory>, String>((ref, language) async {
  final repository = ref.watch(ramayanRepositoryProvider);
  return repository.getCategories(language);
});

/// Query parameter record for quotes.
class StatusQuoteQueryParam {
  final String language;
  final String categoryId; // '' means All

  const StatusQuoteQueryParam({
    required this.language,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusQuoteQueryParam &&
          language == other.language &&
          categoryId == other.categoryId;

  @override
  int get hashCode => language.hashCode ^ categoryId.hashCode;
}

/// Fetches all quotes for a language (Local Hive -> Remote Sync).
final statusQuotesProvider =
    FutureProvider.family<List<StatusQuote>, StatusQuoteQueryParam>(
        (ref, param) async {
  final repository = ref.watch(ramayanRepositoryProvider);
  return repository.getQuotes(
    param.language,
    categoryId: param.categoryId.isEmpty ? null : param.categoryId,
  );
});

/// Fetches all image URLs dynamically (Local Hive -> Remote Sync + Permanent disk cache).
final statusImageUrlsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(ramayanRepositoryProvider);
  return repository.getImageUrls();
});

// ── UI State Providers ────────────────────────────────────────────────────

/// Currently selected category ID. Empty string = "All".
final selectedStatusCategoryProvider = StateProvider<String>((ref) => '');

// ── Combined Status Items Provider ────────────────────────────────────────

/// Combines quotes + images into a list of [StatusItem] objects.
final statusItemsProvider =
    FutureProvider.family<List<StatusItem>, String>((ref, language) async {
  final selectedCategory = ref.watch(selectedStatusCategoryProvider);

  // Fetch quotes for the selected category (offline-first)
  final quotesAsync = await ref.watch(
    statusQuotesProvider(StatusQuoteQueryParam(
      language: language,
      categoryId: selectedCategory,
    )).future,
  );

  // Fetch image URLs (offline-first with permanent local disk download)
  final imageUrls = await ref.watch(statusImageUrlsProvider.future);

  // Let the randomizer pair them
  final randomizer = ref.watch(statusRandomizerProvider);
  return randomizer.generateStatusItems(
    quotes: quotesAsync,
    imageUrls: imageUrls,
    count: 30,
  );
});

// ── Daily Quote Providers ─────────────────────────────────────────────────

/// Holds the daily selected quote + image URL.
class DailyQuoteSelection {
  final StatusQuote quote;
  final String imageUrl;

  const DailyQuoteSelection({required this.quote, required this.imageUrl});
}

/// Returns a stable day-index derived from the local date.
int _dayIndex() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(DateTime(2020, 1, 1)).inDays;
}

/// Deterministic daily quote + image selection (Offline First).
final dailyQuoteProvider =
    FutureProvider.family<DailyQuoteSelection?, String>((ref, language) async {
  final repository = ref.watch(ramayanRepositoryProvider);

  final quotes = await repository.getQuotes(language);
  final imageUrls = await repository.getImageUrls();

  if (quotes.isEmpty) return null;

  final dayIdx = _dayIndex();
  final quoteIndex = dayIdx % quotes.length;
  final imageIndex =
      imageUrls.isEmpty ? -1 : (dayIdx + 7) % imageUrls.length;

  return DailyQuoteSelection(
    quote: quotes[quoteIndex],
    imageUrl: imageIndex >= 0 ? imageUrls[imageIndex] : '',
  );
});
