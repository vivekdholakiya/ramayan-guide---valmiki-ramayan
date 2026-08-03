import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../models/ramayan_category.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/fast_search_bar.dart';
import '../widgets/ramayan_item_card.dart';
import '../widgets/responsive_container.dart';
import '../widgets/skeleton_loader.dart';
import 'item_detail_screen.dart';

class CategoryScreen extends ConsumerWidget {
  final RamayanCategory category;

  const CategoryScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryTitle = category.getLocalizedTitle(language.code);

    final param = CategoryQueryParam(
      language: language.code,
      categoryId: category.id,
    );

    final asyncFilteredItems = ref.watch(filteredCategoryItemsProvider(param));
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 1;
    if (width >= 1100) {
      crossAxisCount = 3;
    } else if (width >= 650) {
      crossAxisCount = 2;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryTitle,
          style: AppTypography.getStyle(
            languageCode: language.code,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 1280.0,
          child: Column(
            children: [
              FastSearchBar(
                languageCode: language.code,
                hintText: AppStrings.get('category_search_placeholder', language.code),
                onChanged: (query) {
                  ref.read(categorySearchQueryProvider.notifier).state = query;
                },
              ),
              Expanded(
                child: asyncFilteredItems.when(
                  data: (items) {
                    if (items.isEmpty) {
                      final isSearching = ref
                          .watch(categorySearchQueryProvider)
                          .trim()
                          .isNotEmpty;

                      if (isSearching) {
                        return EmptyStateView(
                          languageCode: language.code,
                          type: EmptyStateType.noResults,
                        );
                      } else {
                        // Collection is empty in Firestore for this language (e.g. hi or en before upload)
                        return EmptyStateView(
                          languageCode: language.code,
                          type: EmptyStateType.comingSoon,
                          onActionPressed: () {
                            ref
                                .read(languageProvider.notifier)
                                .setLanguage(AppLanguage.gu);
                          },
                        );
                      }
                    }

                    if (crossAxisCount == 1) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return RamayanItemCard(
                            item: item,
                            languageCode: language.code,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailScreen(item: item),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        mainAxisExtent: 170.0,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return RamayanItemCard(
                          item: item,
                          languageCode: language.code,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ItemDetailScreen(item: item),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const SkeletonItemList(itemCount: 6),
                  error: (err, stack) => EmptyStateView(
                    languageCode: language.code,
                    type: EmptyStateType.error,
                    onActionPressed: () {
                      ref.invalidate(categoryItemsProvider(param));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
