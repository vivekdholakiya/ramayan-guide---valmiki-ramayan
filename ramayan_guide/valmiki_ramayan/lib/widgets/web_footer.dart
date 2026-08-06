import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';
import 'diya_painter.dart';

class WebFooter extends ConsumerWidget {
  final ValueChanged<int>? onNavigate;

  const WebFooter({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSize(36.0),
        horizontal: context.responsiveSize(24.0),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
        border: Border(
          top: BorderSide(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
            width: context.responsiveSize(1.0),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              DiyaWidget(size: context.responsiveSize(32)),
              SizedBox(height: context.responsiveSize(12)),
              Text(
                AppStrings.get('app_title', language.code),
                style: AppTypography.getStyle(
                  languageCode: language.code,
                  fontSize: context.responsiveFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
                ),
              ),
              SizedBox(height: context.responsiveSize(6)),
              Text(
                'Ancient wisdom, beautifully presented.',
                style: AppTypography.getStyle(
                  languageCode: language.code,
                  fontSize: context.responsiveFontSize(13),
                  color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
                ),
              ),
              SizedBox(height: context.responsiveSize(20)),
              if (onNavigate != null)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: context.responsiveSize(24),
                  children: [
                    _footerLink(
                      context,
                      AppStrings.get('nav_home', language.code),
                      () => onNavigate!(0),
                      language.code,
                    ),
                    _footerLink(
                      context,
                      AppStrings.get('nav_categories', language.code),
                      () => onNavigate!(1),
                      language.code,
                    ),
                    _footerLink(
                      context,
                      AppStrings.get('nav_favorites', language.code),
                      () => onNavigate!(2),
                      language.code,
                    ),
                    _footerLink(
                      context,
                      AppStrings.get('nav_settings', language.code),
                      () => onNavigate!(3),
                      language.code,
                    ),
                  ],
                ),
              SizedBox(height: context.responsiveSize(20)),
              Text(
                '© ${DateTime.now().year} Valmiki Ramayan. All rights reserved.',
                style: AppTypography.getStyle(
                  languageCode: language.code,
                  fontSize: context.responsiveFontSize(12),
                  color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(
    BuildContext context,
    String label,
    VoidCallback onTap,
    String languageCode,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: AppTypography.getStyle(
          languageCode: languageCode,
          fontSize: context.responsiveFontSize(13),
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
      ),
    );
  }
}
