import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../models/ramayan_category.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../providers/story_access_provider.dart';
import '../services/ads.dart';
import '../services/context_extensions.dart';
import '../widgets/animated_interactions.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/fast_search_bar.dart';
import '../widgets/ramayan_item_card.dart';
import '../widgets/responsive_container.dart';
import '../widgets/skeleton_loader.dart';

class CategoryScreen extends ConsumerWidget {
  final RamayanCategory category;

  const CategoryScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final storyAccess = ref.watch(storyAccessProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryTitle = category.getLocalizedTitle(language.code);

    final param = CategoryQueryParam(
      language: language.code,
      categoryId: category.id,
    );

    final asyncFilteredItems = ref.watch(filteredCategoryItemsProvider(param));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: context.responsiveSize( context.isIPad? 28 : 24),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryTitle,
          style: AppTypography.getStyle(
            languageCode: language.code,
            fontSize: context.responsiveFontSize( context.isIPad? 28 : 20),
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth:  double.infinity,
          child: Column(
            children: [
              StaggeredEntrance(
                index: 0,
                child: FastSearchBar(
                  languageCode: language.code,
                  hintText: AppStrings.get('category_search_placeholder', language.code),
                  onChanged: (query) {
                    ref.read(categorySearchQueryProvider.notifier).state = query;
                  },
                ),
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

                    final adCount = items.length ~/ 4;
                    final totalCount = items.length + adCount;

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: context.responsiveSize(12.0),
                      ),
                      itemCount: totalCount,
                      itemBuilder: (context, index) {
                        // Ad appears after every 4 stories:
                        // 4 stories -> ad
                        // 4 stories -> ad
                        // 4 stories -> ad

                        final isAd = (index + 1) % 5 == 0;

                        if (isAd) {
                          final adIndex = (index + 1) ~/ 5;

                          return Padding(
                            key: ValueKey('category_native_ad_$adIndex'),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsiveSize(16.0),
                              vertical: context.responsiveSize(8.0),
                            ),
                            child: const NativeAdWidget(
                              templateType: NativeAdTemplateType.small,
                            ),
                          );
                        }

                        // Number of ads that appeared before this index
                        final adsBefore = index ~/ 5;

                        // Original item index
                        final storyIndex = index - adsBefore;

                        final item = items[storyIndex];
                        final isLocked = storyAccess.isStoryLocked(item);

                        return StaggeredEntrance(
                          index: index,
                          child: RamayanItemCard(
                            item: item,
                            languageCode: language.code,
                            isLocked: isLocked,
                            onTap: () => StoryAccessHelper.openStory(
                              context: context,
                              ref: ref,
                              item: item,
                            ),
                          ),
                        );
                      },
                    );

                    // return ListView.builder(
                    //   padding: EdgeInsets.symmetric(
                    //     vertical: context.responsiveSize(12.0),
                    //   ),
                    //
                    //   // 4 stories + 1 ad
                    //   // પછી remaining stories
                    //   itemCount: items.length + 1,
                    //
                    //   itemBuilder: (context, index) {
                    //     // Show ONE Native Ad after first 4 stories
                    //     if (index == 4) {
                    //       return Padding(
                    //         key: const ValueKey('category_native_ad'),
                    //         padding: EdgeInsets.symmetric(
                    //           horizontal: context.responsiveSize(16.0),
                    //           vertical: context.responsiveSize(8.0),
                    //         ),
                    //         child: const NativeAdWidget(
                    //           templateType: NativeAdTemplateType.small,
                    //         ),
                    //       );
                    //     }
                    //
                    //     // Map ListView index back to original story index.
                    //     // After the ad, subtract 1 because ad occupies one position.
                    //     final storyIndex = index > 4 ? index - 1 : index;
                    //
                    //     final item = items[storyIndex];
                    //     final isLocked = storyAccess.isStoryLocked(item);
                    //
                    //     return StaggeredEntrance(
                    //       index: index,
                    //       child: RamayanItemCard(
                    //         item: item,
                    //         languageCode: language.code,
                    //         isLocked: isLocked,
                    //         onTap: () => StoryAccessHelper.openStory(
                    //           context: context,
                    //           ref: ref,
                    //           item: item,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );

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
      bottomNavigationBar: Padding(padding: EdgeInsetsGeometry.only(top: context.responsiveSize(10)),child: AdsBannerWidget()),
    );
  }
}
