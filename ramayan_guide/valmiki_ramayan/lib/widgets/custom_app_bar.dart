import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/language_selection_screen.dart';
import '../services/context_extensions.dart';
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
              icon: Icon(
                Icons.arrow_back_rounded,
                size: context.responsiveSize(24),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : Padding(
              padding: EdgeInsets.only(left: context.responsiveSize(16.0)),
              child: Center(
                child: DiyaWidget(size: context.responsiveSize(28)),
              ),
            ),
      title: Text(
        appTitle,
        style: AppTypography.getStyle(
          languageCode: language.code,
          fontSize: context.responsiveFontSize(18),
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
      ),
      actions: [
        if (onSearchPressed != null)
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              size: context.responsiveSize(24),
            ),
            tooltip: AppStrings.get('search_placeholder', language.code),
            onPressed: onSearchPressed,
          ),
        IconButton(
          icon: Icon(
            Icons.language_rounded,
            size: context.responsiveSize(24),
          ),
          tooltip: AppStrings.get('nav_settings', language.code),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LanguageSelectionScreen(isFromSettings: true,)),
            );
          },
        ),
        IconButton(
          icon: Icon(
            isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            size: context.responsiveSize(24),
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
            icon: Icon(
              Icons.settings_rounded,
              size: context.responsiveSize(24),
            ),
            tooltip: AppStrings.get('nav_settings', language.code),
            onPressed: onSettingsPressed,
          ),
        SizedBox(width: context.responsiveSize(4)),
      ],
    );
  }
}
