import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/language_provider.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
        border: Border(
          top: BorderSide(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const DiyaWidget(size: 32),
              const SizedBox(height: 12),
              Text(
                AppStrings.get('app_title', language.code),
                style: AppTypography.getStyle(
                  languageCode: language.code,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ancient wisdom, beautifully presented.',
                style: AppTypography.getStyle(
                  languageCode: language.code,
                  fontSize: 13,
                  color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
                ),
              ),
              const SizedBox(height: 20),
              if (onNavigate != null)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
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
              const SizedBox(height: 20),
              Text(
                '© ${DateTime.now().year} Valmiki Ramayan. All rights reserved.',
                style: AppTypography.getStyle(
                  languageCode: language.code,
                  fontSize: 12,
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
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
      ),
    );
  }
}
