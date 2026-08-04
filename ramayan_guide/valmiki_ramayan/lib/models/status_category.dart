import 'package:cloud_firestore/cloud_firestore.dart';

/// StatusCategory represents a quote category document
/// fetched from Firestore at: /RamayanQuotes/{language}/categories/{docId}
class StatusCategory {
  final String id;
  final String name;
  final String language;

  const StatusCategory({
    required this.id,
    required this.name,
    required this.language,
  });

  /// Safely parse a Firestore DocumentSnapshot into a StatusCategory.
  factory StatusCategory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StatusCategory(
      id: doc.id,
      name: data['name']?.toString().trim() ?? doc.id,
      language: data['language']?.toString().trim() ?? 'gu',
    );
  }

  factory StatusCategory.fromJson(Map<String, dynamic> json) {
    return StatusCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      language: json['language']?.toString() ?? 'gu',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'language': language,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
