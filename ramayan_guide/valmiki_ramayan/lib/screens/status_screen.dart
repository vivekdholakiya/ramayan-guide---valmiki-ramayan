import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/status_item.dart';
import '../providers/language_provider.dart';
import '../providers/status_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/responsive_container.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_card.dart';
import '../widgets/status_category_selector.dart';
import 'status_viewer_screen.dart';

/// StatusScreen is the main Status tab screen.
///
/// Structure:
///   AppBar (matching existing app style)
///   ↓
///   StatusCategorySelector (horizontal scrollable chips from Firebase)
///   ↓
///   ListView of StatusCards (9:16, dynamically paired quote + image)
///
/// Loading  → shimmer skeletons
/// Empty    → Gujarati empty state message
/// Error    → friendly error state with retry button
class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Scaffold(
      appBar: isDesktop
          ? null
          : _StatusAppBar(languageCode: language.code, isDark: isDark),
      body: SafeArea(
        child: _StatusBody(languageCode: language.code),
      ),
    );
  }
}

/// Custom AppBar for Status screen — matches the existing CustomAppBar style.
class _StatusAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String languageCode;
  final bool isDark;

  const _StatusAppBar({required this.languageCode, required this.isDark});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Center(
          child: Icon(Icons.auto_awesome_rounded,
              color: AppColors.deepSaffron, size: 26),
        ),
      ),
      title: Text(
        AppStrings.get('nav_status', languageCode),
        style: AppTypography.getStyle(
          languageCode: languageCode,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
      ),
      actions: [
        // Language toggle matches existing CustomAppBar behavior
        // PopupMenuButton<String>(
        //   icon: const Icon(Icons.language_rounded),
        //   tooltip: AppStrings.get('settings_language', languageCode),
        //   onSelected: (code) {
        //     final lang = AppLanguage.values.firstWhere(
        //       (l) => l.code == code,
        //       orElse: () => AppLanguage.gu,
        //     );
        //     ref.read(languageProvider.notifier).setLanguage(lang);
        //   },
        //   itemBuilder: (_) => AppLanguage.values
        //       .map((lang) => PopupMenuItem(
        //             value: lang.code,
        //             child: Text(lang.label),
        //           ))
        //       .toList(),
        // ),
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: AppStrings.get('retry_btn', languageCode),
          onPressed: () {
            ref.read(statusServiceProvider).clearCache();
            ref.invalidate(statusCategoriesProvider);
            ref.invalidate(statusImageUrlsProvider);
            ref.invalidate(statusItemsProvider);
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// Main body of StatusScreen — orchestrates loading/error/content states.
class _StatusBody extends ConsumerWidget {
  final String languageCode;

  const _StatusBody({required this.languageCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync =
        ref.watch(statusCategoriesProvider(languageCode));
    final selectedCategory = ref.watch(selectedStatusCategoryProvider);

    return Column(
      children: [
        // ── Category Selector ─────────────────────────────────────────
        categoriesAsync.when(
          data: (categories) => StatusCategorySelector(
            categories: categories,
            selectedCategoryId: selectedCategory,
            onCategorySelected: (id) {
              ref.read(selectedStatusCategoryProvider.notifier).state = id;
            },
            languageCode: languageCode,
          ),
          loading: () => _CategorySelectorSkeleton(),
          error: (_, _e) => const SizedBox.shrink(),
        ),

        // ── Status Cards ──────────────────────────────────────────────
        Expanded(
          child: _StatusCardList(languageCode: languageCode),
        ),
      ],
    );
  }
}

class _CategorySelectorSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 48,
      color: isDark ? AppColors.darkBackground : AppColors.parchmentLight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(
          5,
          (i) => Container(
            width: 60 + (i % 3) * 20.0,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkCard : AppColors.parchmentCard),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the list of StatusCards with all states handled.
class _StatusCardList extends ConsumerWidget {
  final String languageCode;

  const _StatusCardList({required this.languageCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(statusItemsProvider(languageCode));
    final selectedCategory = ref.watch(selectedStatusCategoryProvider);

    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return EmptyStateView(
            languageCode: languageCode,
            type: EmptyStateType.noResults,
            customTitle: selectedCategory.isEmpty
                ? AppStrings.get('status_empty_title', languageCode)
                : AppStrings.get('status_category_empty_title', languageCode),
            customDesc: selectedCategory.isEmpty
                ? AppStrings.get('status_empty_desc', languageCode)
                : AppStrings.get('status_category_empty_desc', languageCode),
          );
        }

        return _StatusCardScrollView(
          items: items,
          languageCode: languageCode,
        );
      },
      loading: () => const SkeletonStatusGrid(itemCount: 3),
      error: (err, _) => EmptyStateView(
        languageCode: languageCode,
        type: EmptyStateType.error,
        onActionPressed: () {
          ref.read(statusServiceProvider).clearCache();
          ref.invalidate(statusItemsProvider);
          ref.invalidate(statusImageUrlsProvider);
        },
      ),
    );
  }
}

/// Scrollable list of StatusCards with responsive layout.
class _StatusCardScrollView extends StatelessWidget {
  final List<StatusItem> items;
  final String languageCode;

  const _StatusCardScrollView({
    required this.items,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Desktop: 2-column grid; Tablet: 2-column; Phone: 1-column
    if (width >= 900) {
      return _DesktopStatusGrid(items: items, languageCode: languageCode);
    }

    return ResponsiveContainer(
      maxWidth: 480,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: items.length,
        separatorBuilder: (_, _i) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          return _AnimatedStatusCard(
            item: items[index],
            index: index,
            onTap: () {
              Navigator.of(context).push(
                _StatusViewerRoute(
                  screen: StatusViewerScreen(
                    items: items,
                    initialIndex: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DesktopStatusGrid extends StatelessWidget {
  final List<StatusItem> items;
  final String languageCode;

  const _DesktopStatusGrid(
      {required this.items, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 9 / 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _AnimatedStatusCard(
          item: items[index],
          index: index,
          onTap: () {
            Navigator.of(context).push(
              _StatusViewerRoute(
                screen: StatusViewerScreen(
                  items: items,
                  initialIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Staggered entrance animation for each card as it scrolls into view.
class _AnimatedStatusCard extends StatefulWidget {
  final StatusItem item;
  final int index;
  final VoidCallback onTap;

  const _AnimatedStatusCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedStatusCard> createState() => _AnimatedStatusCardState();
}

class _AnimatedStatusCardState extends State<_AnimatedStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger by index (max 300ms delay)
    final delay =
        Duration(milliseconds: (widget.index * 80).clamp(0, 300));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: StatusCard(
          item: widget.item,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

/// Custom page route for StatusViewer with a smooth fade+scale transition.
class _StatusViewerRoute extends PageRouteBuilder {
  final Widget screen;

  _StatusViewerRoute({required this.screen})
      : super(
          pageBuilder: (_, _a, _b) => screen,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (_, animation, _c, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}
