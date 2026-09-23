import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../services/context_extensions.dart';
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
      AppStrings.get('nav_status', language.code),
      AppStrings.get('nav_favorites', language.code),
      AppStrings.get('nav_settings', language.code),
    ];

    return Container(
      height: context.responsiveSize(68.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
            width: context.responsiveSize(1.0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: context.responsiveSize(10),
            offset: Offset(0, context.responsiveSize(2)),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24.0)),
            child: Row(
              children: [
                InkWell(
                  onTap: () => onDestinationSelected(0),
                  borderRadius: BorderRadius.circular(context.responsiveSize(12)),
                  child: Row(
                    children: [
                      DiyaWidget(size: context.responsiveSize(32)),
                      SizedBox(width: context.responsiveSize(12)),
                      Text(
                        AppStrings.get('app_title', language.code),
                        style: AppTypography.getStyle(
                          languageCode: language.code,
                          fontSize: context.responsiveFontSize(20),
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
                Row(
                  children: List.generate(navItems.length, (index) {
                    final isSelected = index == selectedIndex;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(4.0)),
                      child: TextButton(
                        onPressed: () => onDestinationSelected(index),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveSize(16.0),
                            vertical: context.responsiveSize(12.0),
                          ),
                          backgroundColor: isSelected
                              ? AppColors.deepSaffron.withValues(alpha: 0.15)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.responsiveSize(12.0)),
                          ),
                        ),
                        child: Text(
                          navItems[index],
                          style: AppTypography.getStyle(
                            languageCode: language.code,
                            fontSize: context.responsiveFontSize(15),
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
                SizedBox(width: context.responsiveSize(16)),
                PopupMenuButton<AppLanguage>(
                  icon: Icon(
                    Icons.language_rounded,
                    size: context.responsiveSize(24),
                  ),
                  // tooltip: AppStrings.get('settings_language', language.code),
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
                            Icon(
                              Icons.check_rounded,
                              color: AppColors.deepSaffron,
                              size: context.responsiveSize(18),
                            )
                          else
                            SizedBox(width: context.responsiveSize(18)),
                          SizedBox(width: context.responsiveSize(8)),
                          Text(
                            lang.label,
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    size: context.responsiveSize(24),
                    color: isDark ? AppColors.warmGold : AppColors.deepSaffron,
                  ),
                  // tooltip: AppStrings.get('settings_theme', language.code),
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
