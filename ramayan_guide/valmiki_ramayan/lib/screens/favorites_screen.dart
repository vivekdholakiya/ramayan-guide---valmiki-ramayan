import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';
import '../widgets/animated_interactions.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/ramayan_item_card.dart';
import '../widgets/responsive_container.dart';
import 'item_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final favorites = ref.watch(favoritesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: context.responsiveSize(16.0)),
          child: Center(
            child: Icon(
              Icons.bookmark_rounded,
              color: AppColors.deepSaffron,
              size: context.responsiveSize(26),
            ),
          ),
        ),
        title: Text(
          AppStrings.get('nav_favorites', language.code),
          style: AppTypography.getStyle(
            languageCode: language.code,
            fontSize: context.responsiveFontSize(20),
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 1280.0,
          child: favorites.isEmpty
              ? EmptyStateView(
                  languageCode: language.code,
                  type: EmptyStateType.noFavorites,
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsiveSize(12.0),
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    return StaggeredEntrance(
                      index: index,
                      child: RamayanItemCard(
                        item: item,
                        languageCode: language.code,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
