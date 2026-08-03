import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'diya_painter.dart';

class WebDesktopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const WebDesktopNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      AppStrings.get('nav_home', language.code),
      AppStrings.get('nav_categories', language.code),
      AppStrings.get('nav_favorites', language.code),
      AppStrings.get('nav_settings', language.code),
    ];

    return Container(
      height: 68.0,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                // App Brand Logo & Title
                InkWell(
                  onTap: () => onDestinationSelected(0),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      const DiyaWidget(size: 32),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.get('app_title', language.code),
                        style: AppTypography.getStyle(
                          languageCode: language.code,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textLightIvory
                              : AppColors.textDarkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Desktop Navigation Links
                Row(
                  children: List.generate(navItems.length, (index) {
                    final isSelected = index == selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextButton(
                        onPressed: () => onDestinationSelected(index),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          backgroundColor: isSelected
                              ? AppColors.deepSaffron.withValues(alpha: 0.15)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          navItems[index],
                          style: AppTypography.getStyle(
                            languageCode: language.code,
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppColors.deepSaffron
                                : (isDark
                                    ? AppColors.textMutedIvory
                                    : AppColors.textMutedBrown),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 16),

                // Language Popover
                PopupMenuButton<AppLanguage>(
                  icon: const Icon(Icons.language_rounded),
                  tooltip: AppStrings.get('settings_language', language.code),
                  onSelected: (selectedLang) {
                    ref.read(languageProvider.notifier).setLanguage(selectedLang);
                  },
                  itemBuilder: (context) => AppLanguage.values.map((lang) {
                    final isSelected = lang == language;
                    return PopupMenuItem<AppLanguage>(
                      value: lang,
                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check_rounded,
                                color: AppColors.deepSaffron, size: 18)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(lang.label),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                // Theme Mode Switcher Shortcut
                IconButton(
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isDark ? AppColors.warmGold : AppColors.deepSaffron,
                  ),
                  tooltip: AppStrings.get('settings_theme', language.code),
                  onPressed: () {
                    final nextMode =
                        isDark ? AppThemeMode.light : AppThemeMode.dark;
                    ref.read(themeProvider.notifier).setThemeMode(nextMode);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
