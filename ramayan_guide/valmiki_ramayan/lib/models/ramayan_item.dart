import 'package:cloud_firestore/cloud_firestore.dart';

/// RamayanItem represents a single document from Firestore subcollections
/// under RamayanaData/{language}/{categoryId}.
class RamayanItem {
  final String id;
  final String title;
  final String description;
  final String language;
  final String category;

  const RamayanItem({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
  });

  /// Factory constructor to parse Firestore DocumentSnapshot safely without throwing exceptions.
  factory RamayanItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String fallbackLanguage = 'gu',
    String fallbackCategory = '',
  }) {
    final data = doc.data() ?? {};
    final docId = doc.id;

    final title = data['title']?.toString().trim() ??
        data['name']?.toString().trim() ??
        docId;

    final description = data['description']?.toString().trim() ??
        data['details']?.toString().trim() ??
        data['content']?.toString().trim() ??
        '';

    final language = data['language']?.toString().trim() ?? fallbackLanguage;
    final category = data['category']?.toString().trim() ?? fallbackCategory;

    return RamayanItem(
      id: docId,
      title: title,
      description: description,
      language: language,
      category: category,
    );
  }

  /// Factory constructor from JSON Map (for local caching or unit testing).
  factory RamayanItem.fromJson(Map<String, dynamic> json) {
    return RamayanItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      language: json['language']?.toString() ?? 'gu',
      category: json['category']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RamayanItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          category == other.category &&
          language == other.language;

  @override
  int get hashCode => id.hashCode ^ category.hashCode ^ language.hashCode;
}
