import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import 'web_nav_bar.dart';

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
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

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

    if (isDesktop) {
      return Scaffold(
        appBar: WebDesktopNavBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
        ),
        body: child,
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}
