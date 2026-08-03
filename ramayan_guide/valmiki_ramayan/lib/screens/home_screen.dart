import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/ramayan_category.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/diya_painter.dart';
import '../widgets/hero_banner.dart';
import '../widgets/navigation_shell.dart';
import '../widgets/ramayan_item_card.dart';
import '../widgets/responsive_container.dart';
import '../widgets/spiritual_decorations.dart';
import '../widgets/web_footer.dart';
import 'category_screen.dart';
import 'favorites_screen.dart';
import 'item_detail_screen.dart';
import 'settings_screen.dart';

/// MainNavigationScreen wraps the application screens using NavigationShell.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: _onDestinationSelected),
      const CategoriesListScreen(),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];

    return NavigationShell(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onDestinationSelected,
      child: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
    );
  }
}

/// Standalone Categories Overview screen tab
class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 700) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get('nav_categories', language.code),
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.15,
            ),
            itemCount: RamayanCategory.categories.length,
            itemBuilder: (context, index) {
              final category = RamayanCategory.categories[index];
              return CategoryCard(
                category: category,
                languageCode: language.code,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(category: category),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Main Spiritual Home Tab Screen
class HomeScreen extends ConsumerWidget {
  final ValueChanged<int>? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final continueReadingItem = ref.watch(continueReadingProvider);
    final recentlyViewed = ref.watch(historyProvider);
    final favorites = ref.watch(favoritesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    int categoryCrossAxisCount = 2;
    if (width >= 1100) {
      categoryCrossAxisCount = 4;
    } else if (width >= 650) {
      categoryCrossAxisCount = 3;
    }

    return Scaffold(
      appBar: isDesktop
          ? null
          : CustomAppBar(
              onSettingsPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Column(
            children: [
              ResponsiveContainer(
                maxWidth: 1280.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Divine Hero Banner
                    HeroBanner(languageCode: language.code),
                    const SizedBox(height: 8),

                    // 2. Continue Reading Card (Only if active item exists)
                    if (continueReadingItem != null) ...[
                      SpiritualSectionHeader(
                        title: AppStrings.get('continue_reading', language.code),
                        languageCode: language.code,
                        icon: Icons.bookmark_added_rounded,
                      ),
                      RamayanItemCard(
                        item: continueReadingItem,
                        languageCode: language.code,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ItemDetailScreen(item: continueReadingItem),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 3. Main Categories Grid Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.get(
                                'main_categories_header', language.code),
                            style: AppTypography.getStyle(
                              languageCode: language.code,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textLightIvory
                                  : AppColors.textDarkBrown,
                            ),
                          ),
                          const DiyaWidget(size: 20),
                        ],
                      ),
                    ),

                    // 4. Main 8 Categories Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: categoryCrossAxisCount,
                        crossAxisSpacing: 14.0,
                        mainAxisSpacing: 14.0,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: RamayanCategory.categories.length,
                      itemBuilder: (context, index) {
                        final category = RamayanCategory.categories[index];
                        return CategoryCard(
                          category: category,
                          languageCode: language.code,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CategoryScreen(category: category),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // 5. Recently Viewed Section (Only if history exists)
                    if (recentlyViewed.isNotEmpty) ...[
                      const MandalaDivider(),
                      SpiritualSectionHeader(
                        title: AppStrings.get('recently_viewed', language.code),
                        languageCode: language.code,
                        icon: Icons.history_rounded,
                      ),
                      ...recentlyViewed.take(3).map((item) {
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
                      }),
                    ],

                    // 6. Favorites Preview (Only if saved favorites exist)
                    if (favorites.isNotEmpty) ...[
                      const MandalaDivider(),
                      SpiritualSectionHeader(
                        title:
                            AppStrings.get('favorites_preview', language.code),
                        languageCode: language.code,
                        icon: Icons.bookmark_rounded,
                      ),
                      ...favorites.take(3).map((item) {
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
                      }),
                    ],

                    const SizedBox(height: 36),
                  ],
                ),
              ),

              // Desktop Web Footer
              if (isDesktop) WebFooter(onNavigate: onNavigate),
            ],
          ),
        ),
      ),
    );
  }
}
