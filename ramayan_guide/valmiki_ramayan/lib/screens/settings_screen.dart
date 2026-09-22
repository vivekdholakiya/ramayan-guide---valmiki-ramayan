import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../constants/util.dart';
import '../models/app_settings.dart';
import '../providers/font_size_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../services/context_extensions.dart';
import '../widgets/animated_interactions.dart';
import '../widgets/diya_painter.dart';
import '../widgets/responsive_container.dart';
import '../widgets/spiritual_decorations.dart';
import 'language_selection_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_use_screen.dart';

/// Redesigned SettingsScreen — Modern, premium Material 3 UI for Valmiki Ramayan.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _shareApp(BuildContext context, String languageCode) async {
    final text = '${AppStrings.get('share_text', languageCode)}\n$appUrl';
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
    await Share.share(text, sharePositionOrigin: origin);
  }

  Future<void> _rateApp() async {
    final uri = Uri.parse(appUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);
    final fontSizeOption = ref.watch(fontSizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = language.code;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.parchmentLight;
    final cardBg = isDark ? AppColors.darkCard : AppColors.parchmentCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.parchmentBorder;
    final textColor = isDark ? AppColors.textLightIvory : AppColors.textDarkBrown;
    final mutedTextColor = isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: context.responsiveSize(16.0)),
          child: Center(
            child: DiyaWidget(size: context.responsiveSize(28)),
          ),
        ),
        title: Text(
          AppStrings.get('settings_title', langCode),
          style: AppTypography.getStyle(
            languageCode: langCode,
            fontSize: context.responsiveFontSize(20),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 800.0,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(20.0),
              vertical: context.responsiveSize(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Language Card
                StaggeredEntrance(
                  index: 0,
                  child: _buildSettingsCard(
                    context: context,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    icon: Icons.language_rounded,
                    title: AppStrings.get('settings_language', langCode),
                    subtitle: language.label,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveSize(12),
                        vertical: context.responsiveSize(5),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepSaffron.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(context.responsiveSize(16)),
                        border: Border.all(color: AppColors.deepSaffron.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            language.label,
                            style: AppTypography.getStyle(
                              languageCode: langCode,
                              fontSize: context.responsiveFontSize(13),
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepSaffron,
                            ),
                          ),
                          SizedBox(width: context.responsiveSize(4)),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: context.responsiveSize(18),
                            color: AppColors.deepSaffron,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LanguageSelectionScreen(isFromSettings: true),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.responsiveSize(12)),

                // 2. Theme Card
                StaggeredEntrance(
                  index: 1,
                  child: Container(
                    padding: EdgeInsets.all(context.responsiveSize(18.0)),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(context.responsiveSize(20.0)),
                      border: Border.all(
                        color: borderColor,
                        width: context.responsiveSize(1.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(context.responsiveSize(10.0)),
                              decoration: BoxDecoration(
                                color: AppColors.deepSaffron.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(context.responsiveSize(14.0)),
                              ),
                              child: Icon(
                                Icons.palette_rounded,
                                color: AppColors.deepSaffron,
                                size: context.responsiveSize(22),
                              ),
                            ),
                            SizedBox(width: context.responsiveSize(14)),
                            Expanded(
                              child: Text(
                                AppStrings.get('settings_theme', langCode),
                                style: AppTypography.getStyle(
                                  languageCode: langCode,
                                  fontSize: context.responsiveFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.responsiveSize(16)),
                        Row(
                          children: AppThemeMode.values.map((mode) {
                            final isSelected = themeMode == mode;
                            final label = AppStrings.get('theme_${mode.key}', langCode);
                            IconData iconData;
                            if (mode == AppThemeMode.light) {
                              iconData = Icons.wb_sunny_rounded;
                            } else if (mode == AppThemeMode.dark) {
                              iconData = Icons.nightlight_round;
                            } else {
                              iconData = Icons.brightness_auto_rounded;
                            }

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(4.0)),
                                child: TapScaleEffect(
                                  onTap: () {
                                    ref.read(themeProvider.notifier).setThemeMode(mode);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      vertical: context.responsiveSize(12.0),
                                      horizontal: context.responsiveSize(8.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.deepSaffron
                                          : (isDark
                                              ? AppColors.darkBackground
                                              : AppColors.parchmentLight),
                                      borderRadius: BorderRadius.circular(context.responsiveSize(16.0)),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.deepSaffron
                                            : borderColor,
                                        width: context.responsiveSize(1.0),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          iconData,
                                          size: context.responsiveSize(20),
                                          color: isSelected ? Colors.white : AppColors.deepSaffron,
                                        ),
                                        SizedBox(height: context.responsiveSize(6)),
                                        Text(
                                          label,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.getStyle(
                                            languageCode: langCode,
                                            fontSize: context.responsiveFontSize(12),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? Colors.white : textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSize(12)),

                // 3. Text Size Card
                StaggeredEntrance(
                  index: 2,
                  child: Container(
                    padding: EdgeInsets.all(context.responsiveSize(18.0)),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(context.responsiveSize(20.0)),
                      border: Border.all(
                        color: borderColor,
                        width: context.responsiveSize(1.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(context.responsiveSize(10.0)),
                              decoration: BoxDecoration(
                                color: AppColors.deepSaffron.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(context.responsiveSize(14.0)),
                              ),
                              child: Icon(
                                Icons.format_size_rounded,
                                color: AppColors.deepSaffron,
                                size: context.responsiveSize(22),
                              ),
                            ),
                            SizedBox(width: context.responsiveSize(14)),
                            Expanded(
                              child: Text(
                                AppStrings.get('settings_font_size', langCode),
                                style: AppTypography.getStyle(
                                  languageCode: langCode,
                                  fontSize: context.responsiveFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.responsiveSize(16)),
                        Wrap(
                          spacing: context.responsiveSize(8.0),
                          runSpacing: context.responsiveSize(8.0),
                          children: AppFontSize.values.map((size) {
                            final isSelected = fontSizeOption == size;
                            final label = AppStrings.get('font_${size.key}', langCode);

                            return TapScaleEffect(
                              onTap: () {
                                ref.read(fontSizeProvider.notifier).setFontSize(size);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.responsiveSize(16.0),
                                  vertical: context.responsiveSize(10.0),
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.deepSaffron
                                      : (isDark
                                          ? AppColors.darkBackground
                                          : AppColors.parchmentLight),
                                  borderRadius: BorderRadius.circular(context.responsiveSize(16.0)),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.deepSaffron
                                        : borderColor,
                                    width: context.responsiveSize(1.0),
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: AppTypography.getStyle(
                                    languageCode: langCode,
                                    fontSize: context.responsiveFontSize(13),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : textColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSize(28)),

                // ── SECTION 2: Support ────────────────────────────────────
                StaggeredEntrance(
                  index: 3,
                  child: _buildSectionHeader(
                    context,
                    AppStrings.get('sec_support', langCode),
                    Icons.favorite_rounded,
                    textColor,
                    langCode,
                  ),
                ),
                SizedBox(height: context.responsiveSize(12)),

                // Share App Card
                StaggeredEntrance(
                  index: 4,
                  child: _buildSettingsCard(
                    context: context,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    icon: Icons.share_rounded,
                    title: AppStrings.get('setting_share_app', langCode),
                    subtitle: AppStrings.get('setting_share_subtitle', langCode),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: context.responsiveSize(16),
                      color: AppColors.deepSaffron,
                    ),
                    onTap: () => _shareApp(context, langCode),
                  ),
                ),
                SizedBox(height: context.responsiveSize(12)),

                // Rate App Card
                StaggeredEntrance(
                  index: 5,
                  child: _buildSettingsCard(
                    context: context,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    icon: Icons.star_rounded,
                    title: AppStrings.get('setting_rate_app', langCode),
                    subtitle: AppStrings.get('setting_rate_subtitle', langCode),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: context.responsiveSize(16),
                      color: AppColors.deepSaffron,
                    ),
                    onTap: _rateApp,
                  ),
                ),
                SizedBox(height: context.responsiveSize(28)),

                // ── SECTION 3: Legal ──────────────────────────────────────
                StaggeredEntrance(
                  index: 6,
                  child: _buildSectionHeader(
                    context,
                    AppStrings.get('sec_legal', langCode),
                    Icons.policy_rounded,
                    textColor,
                    langCode,
                  ),
                ),
                SizedBox(height: context.responsiveSize(12)),

                // Privacy Policy Card
                StaggeredEntrance(
                  index: 7,
                  child: _buildSettingsCard(
                    context: context,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    icon: Icons.privacy_tip_rounded,
                    title: AppStrings.get('settings_privacy', langCode),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: context.responsiveSize(22),
                      color: AppColors.deepSaffron,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.responsiveSize(12)),

                // Terms & Conditions Card
                StaggeredEntrance(
                  index: 8,
                  child: _buildSettingsCard(
                    context: context,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    icon: Icons.description_rounded,
                    title: AppStrings.get('settings_terms', langCode),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: context.responsiveSize(22),
                      color: AppColors.deepSaffron,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
                      );
                    },
                  ),
                ),
                const MandalaDivider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color textColor,
    String langCode,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: context.responsiveSize(20),
          color: AppColors.deepSaffron,
        ),
        SizedBox(width: context.responsiveSize(8)),
        Text(
          title,
          style: AppTypography.getStyle(
            languageCode: langCode,
            fontSize: context.responsiveFontSize(16),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color mutedTextColor,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return TapScaleEffect(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(context.responsiveSize(20.0)),
          border: Border.all(
            color: borderColor,
            width: context.responsiveSize(1.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSize(18.0),
            vertical: context.responsiveSize(16.0),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSize(10.0)),
                decoration: BoxDecoration(
                  color: AppColors.deepSaffron.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(context.responsiveSize(14.0)),
                ),
                child: Icon(
                  icon,
                  color: AppColors.deepSaffron,
                  size: context.responsiveSize(22),
                ),
              ),
              SizedBox(width: context.responsiveSize(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.getStyle(
                        languageCode: 'gu',
                        fontSize: context.responsiveFontSize(15.5),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      SizedBox(height: context.responsiveSize(3)),
                      Text(
                        subtitle,
                        style: AppTypography.getStyle(
                          languageCode: 'gu',
                          fontSize: context.responsiveFontSize(13),
                          color: mutedTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
