import 'dart:math';
import '../models/status_item.dart';
import '../models/status_quote.dart';

/// StatusRandomizer produces a shuffled list of [StatusItem] objects
/// by pairing quotes with background images.
///
/// Rules:
///  - Never crashes if images or quotes list is empty.
///  - Never hardcodes image count.
///  - Uses modulo cycling so images repeat evenly if fewer than quotes.
///  - Fisher-Yates shuffle ensures no consecutive duplicates.
///  - All randomization is isolated here — no Random() calls in UI widgets.
class StatusRandomizer {
  final _random = Random();

  /// Generates a shuffled list of [StatusItem] from available quotes + images.
  ///
  /// [count] is the number of items to generate. Defaults to 20.
  /// If [quotes] or [imageUrls] is empty, returns an empty list gracefully.
  List<StatusItem> generateStatusItems({
    required List<StatusQuote> quotes,
    required List<String> imageUrls,
    int count = 20,
  }) {
    if (quotes.isEmpty || imageUrls.isEmpty) return [];

    // Work on copies so we don't mutate the originals
    final shuffledQuotes = List<StatusQuote>.from(quotes);
    final shuffledImages = List<String>.from(imageUrls);

    _fisherYatesShuffle(shuffledQuotes);
    _fisherYatesShuffle(shuffledImages);

    // Clamp count to available quotes (avoid infinite empty repetitions)
    final actualCount = count.clamp(1, quotes.length * 3);

    final items = <StatusItem>[];
    for (int i = 0; i < actualCount; i++) {
      final quote = shuffledQuotes[i % shuffledQuotes.length];
      final imageUrl = shuffledImages[i % shuffledImages.length];
      items.add(StatusItem(quote: quote, imageUrl: imageUrl));
    }

    return items;
  }

  /// Shuffles [list] in-place using Fisher-Yates algorithm.
  void _fisherYatesShuffle<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// Generates a fresh single [StatusItem] from available data,
  /// used when swiping to the next status in the viewer.
  StatusItem? nextRandom({
    required List<StatusQuote> quotes,
    required List<String> imageUrls,
    StatusItem? excluding,
  }) {
    if (quotes.isEmpty || imageUrls.isEmpty) return null;

    final quotesCopy = List<StatusQuote>.from(quotes);
    final imagesCopy = List<String>.from(imageUrls);
    _fisherYatesShuffle(quotesCopy);
    _fisherYatesShuffle(imagesCopy);

    // Try to pick a different quote than the excluded one
    StatusQuote chosenQuote = quotesCopy.first;
    if (excluding != null && quotesCopy.length > 1) {
      chosenQuote = quotesCopy.firstWhere(
        (q) => q.id != excluding.quote.id,
        orElse: () => quotesCopy.first,
      );
    }

    // Try to pick a different image
    String chosenImage = imagesCopy.first;
    if (excluding != null && imagesCopy.length > 1) {
      chosenImage = imagesCopy.firstWhere(
        (url) => url != excluding.imageUrl,
        orElse: () => imagesCopy.first,
      );
    }

    return StatusItem(quote: chosenQuote, imageUrl: chosenImage);
  }
}
