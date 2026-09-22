import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';
import 'diya_painter.dart';

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
      // Status tab — new addition
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

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard
              : AppColors.parchmentCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
            bottom: Radius.circular(0),
          ),
          border: Border(top: BorderSide(color: isDark
              ? AppColors.darkBorder
              : AppColors.parchmentBorder,),
            right: BorderSide(color: isDark
                ? AppColors.darkBorder
                : AppColors.parchmentBorder,),
            left: BorderSide(color: isDark
                ? AppColors.darkBorder
                : AppColors.parchmentBorder,),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
            bottom: Radius.circular(0),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: context.responsiveSize(72),
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
            indicatorColor: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.15),


            // // --- Icon Styling ---
            // selectedIconTheme: const IconThemeData(
            //   size: 30, // Increased size for selected icon
            //   color: Colors.blueAccent,
            // ),
            // unselectedIconTheme: const IconThemeData(
            //   size: 24, // Standard size for unselected
            //   color: Colors.grey,
            // ),
            //
            // // --- Label Styling ---
            // selectedLabelStyle: const TextStyle(
            //   fontSize: 14,
            //   fontWeight: FontWeight.bold,
            //   letterSpacing: 0.5,
            // ),
            // unselectedLabelStyle: const TextStyle(
            //   fontSize: 12,
            //   fontWeight: FontWeight.normal,
            // ),
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
