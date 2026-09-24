import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ramayan_item.dart';
import '../services/firestore_service.dart';

import 'offline_provider.dart';
import 'story_access_provider.dart';

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

int getKandaOrderIndex(RamayanItem item) {
  final titleLower = item.title.toLowerCase();
  final idLower = item.id.toLowerCase();
  final text = '$idLower $titleLower';

  if (text.contains('bal') ||
      text.contains('બાલ') ||
      text.contains('बाल') ||
      idLower.startsWith('1') ||
      idLower.contains('kand_1') ||
      idLower.contains('kand1')) {
    return 1;
  }
  if (text.contains('ayodh') ||
      text.contains('અયોધ્યા') ||
      text.contains('अयोध्या') ||
      idLower.startsWith('2') ||
      idLower.contains('kand_2') ||
      idLower.contains('kand2')) {
    return 2;
  }
  if (text.contains('arany') ||
      text.contains('અરણ્ય') ||
      text.contains('अरण्य') ||
      idLower.startsWith('3') ||
      idLower.contains('kand_3') ||
      idLower.contains('kand3')) {
    return 3;
  }
  if (text.contains('kishkindh') ||
      text.contains('કિષ્કિંધા') ||
      text.contains('किष्किં') ||
      text.contains('किष्किन्') ||
      idLower.startsWith('4') ||
      idLower.contains('kand_4') ||
      idLower.contains('kand4')) {
    return 4;
  }
  if (text.contains('sundar') ||
      text.contains('સુંદર') ||
      text.contains('सुंदर') ||
      text.contains('सुन्दर') ||
      idLower.startsWith('5') ||
      idLower.contains('kand_5') ||
      idLower.contains('kand5')) {
    return 5;
  }
  if (text.contains('yuddh') ||
      text.contains('lanka') ||
      text.contains('યુદ્ધ') ||
      text.contains('युद्ध') ||
      text.contains('લંકા') ||
      text.contains('लंका') ||
      idLower.startsWith('6') ||
      idLower.contains('kand_6') ||
      idLower.contains('kand6')) {
    return 6;
  }
  if (text.contains('uttar') ||
      text.contains('ઉત્તર') ||
      text.contains('उत्तर') ||
      idLower.startsWith('7') ||
      idLower.contains('kand_7') ||
      idLower.contains('kand7')) {
    return 7;
  }

  // Fallback check for numbers 1 to 7 in ID/title
  final match = RegExp(r'\d+').firstMatch(text);
  if (match != null) {
    final parsed = int.tryParse(match.group(0) ?? '');
    if (parsed != null && parsed >= 1 && parsed <= 7) {
      return parsed;
    }
  }

  return 999;
}

/// CategoryItemsFamily fetches items from Repository (Local Hive -> Remote Sync)
final categoryItemsProvider = FutureProvider.family
    .autoDispose<List<RamayanItem>, CategoryQueryParam>((ref, param) async {
  final repository = ref.watch(ramayanRepositoryProvider);
  final items = await repository.getRamayanItems(
    param.language,
    param.categoryId,
  );

  final List<RamayanItem> resultList;
  // For Seven Kandas category ('sath_kand'), ensure strict 1..7 chronological order
  if (param.categoryId == 'sath_kand') {
    final sortedItems = List<RamayanItem>.from(items);
    sortedItems.sort((a, b) =>
        getKandaOrderIndex(a).compareTo(getKandaOrderIndex(b)));
    resultList = sortedItems;
  } else {
    resultList = items;
  }

  if (resultList.isNotEmpty) {
    Future.microtask(() {
      ref.read(storyAccessProvider.notifier).registerCategoryOrder(
            param.categoryId,
            resultList.map((i) => i.id).toList(),
          );
    });
  }

  return resultList;
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
