import 'package:cloud_firestore/cloud_firestore.dart';

/// StatusQuote represents a single devotional Gujarati quote document
/// fetched from Firestore at: /RamayanQuotes/{language}/quotes/{docId}
class StatusQuote {
  final String id;
  final String text;
  final String category;
  final String categoryId;
  final String language;

  const StatusQuote({
    required this.id,
    required this.text,
    required this.category,
    required this.categoryId,
    required this.language,
  });

  /// Safely parse a Firestore DocumentSnapshot into a StatusQuote.
  factory StatusQuote.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StatusQuote(
      id: doc.id,
      text: data['text']?.toString().trim() ?? '',
      category: data['category']?.toString().trim() ?? '',
      categoryId: data['categoryId']?.toString().trim() ?? '',
      language: data['language']?.toString().trim() ?? 'gu',
    );
  }

  factory StatusQuote.fromJson(Map<String, dynamic> json) {
    return StatusQuote(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      language: json['language']?.toString() ?? 'gu',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'category': category,
        'categoryId': categoryId,
        'language': language,
      };

  bool get isValid => text.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusQuote &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          language == other.language;

  @override
  int get hashCode => id.hashCode ^ language.hashCode;
}
