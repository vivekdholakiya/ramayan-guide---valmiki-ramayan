import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/status_item.dart';
import '../providers/language_provider.dart';
import '../providers/status_provider.dart';
import '../services/ads.dart';
import '../services/context_extensions.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/responsive_container.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_card.dart';
import '../widgets/status_category_selector.dart';
import 'status_viewer_screen.dart';

/// StatusScreen is the main Status tab screen.
class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _StatusAppBar(languageCode: language.code, isDark: isDark),
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
      leading: Padding(
        padding: EdgeInsets.only(
          left: context.responsiveSize(context.isIPad ? 20.0 : 16.0),
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.deepSaffron,
            size: context.responsiveSize(context.isIPad ? 28 : 26),
          ),
        ),
      ),
      title: Text(
        AppStrings.get('nav_status', languageCode),
        style: AppTypography.getStyle(
          languageCode: languageCode,
          fontSize: context.responsiveFontSize(context.isIPad ? 28 : 20),
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            size: context.responsiveSize(context.isIPad ? 28 : 24),
          ),
          // tooltip: AppStrings.get('retry_btn', languageCode),
          onPressed: () {
            ref.read(statusServiceProvider).clearCache();
            ref.invalidate(statusCategoriesProvider);
            ref.invalidate(statusImageUrlsProvider);
            ref.invalidate(statusItemsProvider);
          },
        ),
        SizedBox(width: context.responsiveSize(context.isIPad ? 8 : 4)),
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
          error: (_, e) => const SizedBox.shrink(),
        ),
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
      height: context.responsiveSize(48),
      color: isDark ? AppColors.darkBackground : AppColors.parchmentLight,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(12),
        vertical: context.responsiveSize(8),
      ),
      child: Row(
        children: List.generate(
          5,
          (i) => Container(
            width: context.responsiveSize(60 + (i % 3) * 20.0),
            margin: EdgeInsets.only(right: context.responsiveSize(8)),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkCard : AppColors.parchmentCard),
              borderRadius: BorderRadius.circular(context.responsiveSize(20)),
            ),
          ),
        ),
      ),
    );
  }
}

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

class _StatusCardScrollView extends StatelessWidget {
  final List<StatusItem> items;
  final String languageCode;

  const _StatusCardScrollView({
    required this.items,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return
      context.isIPad ?
      ResponsiveContainer(
        maxWidth: context.screenHeight/2 - 90,
        child: AlignedGridView.count(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSize(20),
            vertical: context.responsiveSize(16),
          ),
          itemCount: items.length,
          crossAxisSpacing: context.responsiveSize(20),
          mainAxisSpacing: context.responsiveSize(20),
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
          }, crossAxisCount: 1,
        ),
      )

          :
      ResponsiveContainer(
      maxWidth: context.screenWidth - 20 ,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(20),
          vertical: context.responsiveSize(16),
        ),
        itemCount: items.length,
        separatorBuilder: (_, i) => SizedBox(height: context.responsiveSize(20)),
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

class _StatusViewerRoute extends PageRouteBuilder {
  final Widget screen;

  _StatusViewerRoute({required this.screen})
      : super(
          pageBuilder: (_, animation, secondaryAnimation) => screen,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
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
