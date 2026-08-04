import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/status_category.dart';
import '../models/status_item.dart';
import '../models/status_quote.dart';
import '../services/status_randomizer.dart';
import '../services/status_service.dart';

// ── Service Providers ─────────────────────────────────────────────────────

final statusServiceProvider = Provider<StatusService>((ref) {
  return StatusService();
});

final statusRandomizerProvider = Provider<StatusRandomizer>((ref) {
  return StatusRandomizer();
});

// ── Data Fetching Providers ───────────────────────────────────────────────

/// Fetches all quote categories for the given language.
final statusCategoriesProvider =
    FutureProvider.family<List<StatusCategory>, String>((ref, language) async {
  final service = ref.watch(statusServiceProvider);
  return service.fetchCategories(language);
});

/// Fetches all quotes for a language. If categoryId is non-empty, filters by category.
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

final statusQuotesProvider =
    FutureProvider.family<List<StatusQuote>, StatusQuoteQueryParam>(
        (ref, param) async {
  final service = ref.watch(statusServiceProvider);
  return service.fetchQuotes(
    param.language,
    categoryId: param.categoryId.isEmpty ? null : param.categoryId,
  );
});

/// Fetches all image URLs dynamically from /RamayanQuotes/imageUrl document.
final statusImageUrlsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(statusServiceProvider);
  return service.fetchImageUrls();
});

// ── UI State Providers ────────────────────────────────────────────────────

/// Currently selected category ID. Empty string = "All".
final selectedStatusCategoryProvider = StateProvider<String>((ref) => '');

// ── Combined Status Items Provider ────────────────────────────────────────

/// Combines quotes + images into a shuffled list of [StatusItem] objects.
/// Filters quotes by [selectedStatusCategoryProvider] locally — no extra Firebase call.
final statusItemsProvider =
    FutureProvider.family<List<StatusItem>, String>((ref, language) async {
  final selectedCategory = ref.watch(selectedStatusCategoryProvider);

  // Fetch quotes for the selected category (cached by StatusService)
  final quotesAsync = await ref.watch(
    statusQuotesProvider(StatusQuoteQueryParam(
      language: language,
      categoryId: selectedCategory,
    )).future,
  );

  // Fetch image URLs (cached after first load)
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
/// Aug 4 → one number; Aug 5 → next number. Never uses Random().
int _dayIndex() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(DateTime(2020, 1, 1)).inDays;
}

/// Deterministic daily quote + image selection.
///
/// Algorithm:
///   quoteIndex = dayIndex % quotes.length
///   imageIndex = (dayIndex + 7) % images.length  ← +7 offset ensures
///                                                    quote/image combos
///                                                    change independently
///
/// Same day → same quote + same image (never rebuilds randomly).
/// Next day → naturally advances to next pair.
/// Handles any number of quotes or images — never hardcoded.
final dailyQuoteProvider =
    FutureProvider.family<DailyQuoteSelection?, String>((ref, language) async {
  final service = ref.watch(statusServiceProvider);

  final quotes = await service.fetchQuotes(language);
  final imageUrls = await service.fetchImageUrls();

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
