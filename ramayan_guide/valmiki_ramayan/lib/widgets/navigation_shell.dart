import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';

class NavigationShell extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const NavigationShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedColor = isDark ? AppColors.brightSaffron : AppColors.deepSaffron;
    final unselectedColor = isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown;
    final selectedIconSize = context.isIPad ? 32.0 : 26.0;
    final unselectedIconSize = context.isIPad ? 28.0 : 24.0;
    final selectedFontSize = context.isIPad ? 16.0 : 12.0;
    final unselectedFontSize = context.isIPad ? 14.0 : 11.0;
    final barHeight = context.isIPad ? 86.0 : 70.0;
    final topRadius = Radius.circular(context.isIPad ? 26.0 : 20.0);

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: AppStrings.get('nav_home', language.code),
      ),
      NavigationDestination(
        icon: const Icon(Icons.grid_view_outlined),
        selectedIcon: const Icon(Icons.grid_view_rounded),
        label: AppStrings.get('nav_categories', language.code),
      ),
      NavigationDestination(
        icon: const Icon(Icons.auto_awesome_outlined),
        selectedIcon: const Icon(Icons.auto_awesome_rounded),
        label: AppStrings.get('nav_status', language.code),
      ),
      NavigationDestination(
        icon: const Icon(Icons.bookmark_outline_rounded),
        selectedIcon: const Icon(Icons.bookmark_rounded),
        label: AppStrings.get('nav_favorites', language.code),
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: AppStrings.get('nav_settings', language.code),
      ),
    ];

    final navigationBarTheme = NavigationBarThemeData(
      height: barHeight,
      indicatorColor: selectedColor.withValues(alpha: isDark ? 0.22 : 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            size: selectedIconSize,
            color: selectedColor,
          );
        }
        return IconThemeData(
          size: unselectedIconSize,
          color: unselectedColor,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return AppTypography.getStyle(
          languageCode: language.code,
          fontSize: isSelected ? selectedFontSize : unselectedFontSize,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? selectedColor : unselectedColor,
        );
      }),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
          borderRadius: BorderRadius.vertical(
            top: topRadius,
            bottom: Radius.zero,
          ),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
            ),
            right: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
            ),
            left: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: context.isIPad ? 24 : 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: topRadius,
            bottom: Radius.zero,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: navigationBarTheme,
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: barHeight,
              indicatorColor: Colors.transparent,
              labelPadding: EdgeInsets.only(top: context.responsiveSize(4)),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: destinations,
            ),
          ),
        ),
      ),
    );
  }
}

