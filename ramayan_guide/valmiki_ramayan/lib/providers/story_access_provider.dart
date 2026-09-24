import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';
import '../models/ramayan_category.dart';
import '../models/ramayan_item.dart';
import '../screens/item_detail_screen.dart';
import '../services/ads.dart';
import 'category_provider.dart';
import 'language_provider.dart';
import 'offline_provider.dart';

class StoryAccessState {
  final Map<String, List<String>> categoryStoryOrder;

  const StoryAccessState({
    this.categoryStoryOrder = const {},
  });

  bool isStoryLocked(RamayanItem item) {
    // 1. For Seven Kandas ('sath_kand'), Kand 1 (Bal) and Kand 2 (Ayodhya) are strictly free
    if (item.category == 'sath_kand') {
      final kandaIndex = getKandaOrderIndex(item);
      return kandaIndex > 2;
    }

    // 2. Check canonical order recorded for this category
    final order = categoryStoryOrder[item.category];
    if (order != null && order.isNotEmpty) {
      final index = order.indexOf(item.id);
      if (index != -1) {
        return index >= 2;
      }
    }

    // 3. Fallback: If item ID is numeric (e.g. '1', '2', '3'...)
    final numId = int.tryParse(item.id.trim());
    if (numId != null) {
      return numId > 2;
    }

    // Default: If position cannot be confirmed yet, treat as locked for safety
    return true;
  }
}

class StoryAccessNotifier extends StateNotifier<StoryAccessState> {
  final Ref _ref;

  StoryAccessNotifier(this._ref) : super(const StoryAccessState()) {
    _initOrder();
  }

  void _initOrder() {
    final localStorage = _ref.read(localStorageServiceProvider);
    final hiveStorage = _ref.read(hiveStorageServiceProvider);
    final currentLanguage = _ref.read(languageProvider).code;

    final Map<String, List<String>> initialMap = {};

    for (final cat in RamayanCategory.categories) {
      // 1. Try local storage cache
      final savedOrder = localStorage.getCategoryStoryOrder(cat.id);
      if (savedOrder.isNotEmpty) {
        initialMap[cat.id] = savedOrder;
        continue;
      }

      // 2. Try Hive storage
      final hiveItems = hiveStorage.getRamayanItems(currentLanguage, cat.id);
      if (hiveItems != null && hiveItems.isNotEmpty) {
        List<String> ids;
        if (cat.id == 'sath_kand') {
          final items = hiveItems.map((j) => RamayanItem.fromJson(j)).toList();
          items.sort((a, b) =>
              getKandaOrderIndex(a).compareTo(getKandaOrderIndex(b)));
          ids = items.map((i) => i.id).toList();
        } else {
          ids = hiveItems.map((m) => m['id']?.toString() ?? '').toList();
        }
        initialMap[cat.id] = ids;
        localStorage.saveCategoryStoryOrder(cat.id, ids);
      }
    }

    state = StoryAccessState(categoryStoryOrder: initialMap);
  }

  void registerCategoryOrder(String categoryId, List<String> storyIds) {
    if (storyIds.isEmpty) return;
    final currentOrder = state.categoryStoryOrder[categoryId];
    if (currentOrder != null &&
        currentOrder.length == storyIds.length &&
        currentOrder.first == storyIds.first) {
      return;
    }

    final updatedMap = Map<String, List<String>>.from(state.categoryStoryOrder);
    updatedMap[categoryId] = List<String>.from(storyIds);
    state = StoryAccessState(categoryStoryOrder: updatedMap);

    _ref
        .read(localStorageServiceProvider)
        .saveCategoryStoryOrder(categoryId, storyIds);
  }

  bool isStoryLocked(RamayanItem item) => state.isStoryLocked(item);
}

final storyAccessProvider =
    StateNotifierProvider<StoryAccessNotifier, StoryAccessState>((ref) {
  return StoryAccessNotifier(ref);
});

class StoryAccessHelper {
  /// Unified entry point to open any story across the app.
  /// If the story is locked, opens the single existing Rewarded Dialog.
  /// If the user completes the rewarded ad, opens the story.
  /// If free, opens the story directly.
  static void openStory({
    required BuildContext context,
    required WidgetRef ref,
    required RamayanItem item,
  }) {
    final isLocked = ref.read(storyAccessProvider.notifier).isStoryLocked(item);
    if (!isLocked) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(item: item),
        ),
      );
      return;
    }

    final language = ref.read(languageProvider);
    adsControllerVar.showRewardedAd(
      context,
      title: AppStrings.get('ad_unlock_story_title', language.code),
      description: AppStrings.get('ad_unlock_story_desc', language.code),
      watchButtonText: AppStrings.get('ad_watch_btn', language.code),
      maybeLaterText: AppStrings.get('ad_maybe_later_btn', language.code),
      onRewardGranted: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(item: item),
          ),
        );
      },
    );
  }
}
