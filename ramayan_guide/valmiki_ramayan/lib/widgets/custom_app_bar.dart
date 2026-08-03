import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'diya_painter.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchPressed;
  final VoidCallback? onSettingsPressed;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.onSearchPressed,
    this.onSettingsPressed,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final appTitle = AppStrings.get('app_title', language.code);

    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Center(
                child: DiyaWidget(size: 28),
              ),
            ),
      title: Text(
        appTitle,
        style: AppTypography.getStyle(
          languageCode: language.code,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
      ),
      actions: [
        if (onSearchPressed != null)
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: AppStrings.get('search_placeholder', language.code),
            onPressed: onSearchPressed,
          ),
        // Language Toggle Shortcut
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
                    const Icon(Icons.check_rounded, color: AppColors.deepSaffron, size: 18)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(lang.label),
                ],
              ),
            );
          }).toList(),
        ),
        // Theme Mode Toggle Shortcut
        IconButton(
          icon: Icon(
            isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: isDark ? AppColors.warmGold : AppColors.deepSaffron,
          ),
          tooltip: AppStrings.get('settings_theme', language.code),
          onPressed: () {
            final nextMode = isDark ? AppThemeMode.light : AppThemeMode.dark;
            ref.read(themeProvider.notifier).setThemeMode(nextMode);
          },
        ),
        if (onSettingsPressed != null)
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: AppStrings.get('nav_settings', language.code),
            onPressed: onSettingsPressed,
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}
