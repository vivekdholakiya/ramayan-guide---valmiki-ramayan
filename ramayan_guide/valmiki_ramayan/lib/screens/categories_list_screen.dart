
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/ramayan_category.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';
import '../widgets/animated_interactions.dart';
import '../widgets/category_card.dart';
import '../widgets/responsive_container.dart';

import 'category_screen.dart';

/// Standalone Categories Overview screen tab
class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (context.isIPad) {
      crossAxisCount = context.isLandscape ? 4 : 3;
    } else if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 700) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: context.responsiveSize(16.0)),
          child: Center(
            child: Icon(
              Icons.grid_view_rounded,
              color: AppColors.deepSaffron,
              size: context.responsiveSize(26),
            ),
          ),
        ),
        title: Text(
          AppStrings.get('nav_categories', language.code),
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
          child: MasonryGridView.count(
            padding: EdgeInsets.all(context.responsiveSize(16.0)),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: context.responsiveSize(16.0),
            crossAxisSpacing: context.responsiveSize(16.0),
            itemCount: RamayanCategory.categories.length,
            itemBuilder: (context, index) {
              final category = RamayanCategory.categories[index];
              final height = context.responsiveSize(250.0);
              return StaggeredEntrance(
                index: index,
                child: CategoryCard(
                  category: category,
                  languageCode: language.code,
                  height: height,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(category: category),
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
