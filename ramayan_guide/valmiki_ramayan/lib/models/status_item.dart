import 'status_quote.dart';

/// StatusItem pairs one [StatusQuote] with one background [imageUrl].
/// This is the primary data object consumed by status UI widgets.
/// Generation is handled by StatusRandomizer, never by UI widgets directly.
class StatusItem {
  final StatusQuote quote;
  final String imageUrl;

  const StatusItem({
    required this.quote,
    required this.imageUrl,
  });

  /// Whether this item has a valid image URL to display.
  bool get hasImage => imageUrl.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusItem &&
          runtimeType == other.runtimeType &&
          quote.id == other.quote.id &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => quote.id.hashCode ^ imageUrl.hashCode;
}
