import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import 'diya_painter.dart';

class HeroBanner extends StatelessWidget {
  final String languageCode;

  const HeroBanner({
    super.key,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final title = AppStrings.get('app_title', languageCode);
    final subtitle = AppStrings.get('hero_subtitle', languageCode);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF2E1A0C),
                  const Color(0xFF1F1007),
                  const Color(0xFF381C08),
                ]
              : [
                  const Color(0xFFFFF3E0),
                  const Color(0xFFFFE0B2),
                  const Color(0xFFFFF8E1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.2 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.warmGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Background soft radial gold glow
          Positioned(
            right: -40,
            bottom: -40,
            top: -40,
            child: Container(
              width: isDesktop ? 250 : 150,
              height: isDesktop ? 250 : 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmGold.withValues(alpha: isDark ? 0.15 : 0.25),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40.0 : 24.0,
              vertical: isDesktop ? 36.0 : 28.0,
            ),
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _taglineHeader(languageCode),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              style: AppTypography.getStyle(
                                languageCode: languageCode,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textLightIvory
                                    : AppColors.textDarkBrown,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: AppTypography.getStyle(
                                languageCode: languageCode,
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.textMutedIvory
                                    : AppColors.textMutedBrown,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Container(
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.deepSaffron.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.warmGold,
                            width: 2,
                          ),
                        ),
                        child: const DiyaWidget(size: 64),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _taglineHeader(languageCode),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: AppTypography.getStyle(
                          languageCode: languageCode,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textLightIvory
                              : AppColors.textDarkBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: AppTypography.getStyle(
                          languageCode: languageCode,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textMutedIvory
                              : AppColors.textMutedBrown,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _taglineHeader(String languageCode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DiyaWidget(size: 20),
        const SizedBox(width: 8),
        Text(
          'જય શ્રી રામ',
          style: AppTypography.getStyle(
            languageCode: languageCode,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.deepSaffron,
          ),
        ),
      ],
    );
  }
}
