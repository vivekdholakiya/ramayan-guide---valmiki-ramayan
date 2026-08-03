import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../providers/font_size_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/diya_painter.dart';
import '../widgets/responsive_container.dart';
import '../widgets/spiritual_decorations.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);
    final fontSizeOption = ref.watch(fontSizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get('nav_settings', language.code),
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
          maxWidth: 800.0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Language Setting Card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language_rounded,
                        color: AppColors.deepSaffron),
                    title: Text(
                      AppStrings.get('settings_language', language.code),
                      style: AppTypography.getStyle(
                        languageCode: language.code,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      language.label,
                      style: AppTypography.getStyle(
                        languageCode: language.code,
                        color: isDark
                            ? AppColors.textMutedIvory
                            : AppColors.textMutedBrown,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LanguageSelectionScreen(
                              isFromSettings: true),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Theme Mode Setting Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.palette_outlined,
                                color: AppColors.deepSaffron),
                            const SizedBox(width: 12),
                            Text(
                              AppStrings.get('settings_theme', language.code),
                              style: AppTypography.getStyle(
                                languageCode: language.code,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<AppThemeMode>(
                          segments: AppThemeMode.values.map((mode) {
                            return ButtonSegment<AppThemeMode>(
                              value: mode,
                              label: Text(
                                AppStrings.get('theme_${mode.key}', language.code),
                                style: AppTypography.getStyle(
                                  languageCode: language.code,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                          selected: {themeMode},
                          onSelectionChanged: (newSelection) {
                            ref
                                .read(themeProvider.notifier)
                                .setThemeMode(newSelection.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Reading Font Size Setting Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.format_size_rounded,
                                color: AppColors.deepSaffron),
                            const SizedBox(width: 12),
                            Text(
                              AppStrings.get('settings_font_size', language.code),
                              style: AppTypography.getStyle(
                                languageCode: language.code,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<AppFontSize>(
                          segments: AppFontSize.values.map((size) {
                            return ButtonSegment<AppFontSize>(
                              value: size,
                              label: Text(
                                AppStrings.get('font_${size.key}', language.code),
                                style: AppTypography.getStyle(
                                  languageCode: language.code,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                          selected: {fontSizeOption},
                          onSelectionChanged: (newSelection) {
                            ref
                                .read(fontSizeProvider.notifier)
                                .setFontSize(newSelection.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const MandalaDivider(),
                const SizedBox(height: 12),
                // About Section Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const DiyaWidget(size: 36),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.get('app_title', language.code),
                          style: AppTypography.getStyle(
                            languageCode: language.code,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.get('about_description', language.code),
                          textAlign: TextAlign.center,
                          style: AppTypography.getStyle(
                            languageCode: language.code,
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textMutedIvory
                                : AppColors.textMutedBrown,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${AppStrings.get('settings_version', language.code)}: 1.0.0',
                          style: AppTypography.getStyle(
                            languageCode: language.code,
                            fontSize: 12,
                            color: AppColors.deepSaffron,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
