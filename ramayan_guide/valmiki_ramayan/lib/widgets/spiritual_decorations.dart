import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../services/context_extensions.dart';
import 'diya_painter.dart';

/// MandalaDivider renders a sacred mandala-inspired decorative divider.
class MandalaDivider extends StatelessWidget {
  const MandalaDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.responsiveSize(20.0)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: context.responsiveSize(1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warmGold.withValues(alpha: 0.0),
                    AppColors.warmGold.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(12.0)),
            child: DiyaWidget(size: context.responsiveSize(22)),
          ),
          Expanded(
            child: Container(
              height: context.responsiveSize(1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warmGold.withValues(alpha: 0.7),
                    AppColors.warmGold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpiritualSectionHeader extends StatelessWidget {
  final String title;
  final String languageCode;
  final IconData? icon;

  const SpiritualSectionHeader({
    super.key,
    required this.title,
    required this.languageCode,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(16.0),
        vertical: context.responsiveSize(12.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.responsiveSize(6.0)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepSaffron.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.warmGold.withValues(alpha: 0.5),
                width: context.responsiveSize(1),
              ),
            ),
            child: Icon(
              icon ?? Icons.auto_awesome_rounded,
              size: context.responsiveSize(16),
              color: AppColors.deepSaffron,
            ),
          ),
          SizedBox(width: context.responsiveSize(10)),
          Text(
            title,
            style: AppTypography.getStyle(
              languageCode: languageCode,
              fontSize: context.responsiveFontSize(18),
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
            ),
          ),
        ],
      ),
    );
  }
}

/// LotusBadge displays a golden lotus-inspired badge icon.
class LotusBadge extends StatelessWidget {
  final double size;

  const LotusBadge({super.key, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    final responsiveBadgeSize = context.responsiveSize(size);

    return Container(
      width: responsiveBadgeSize,
      height: responsiveBadgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.warmGold.withValues(alpha: 0.3),
            AppColors.deepSaffron.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.warmGold.withValues(alpha: 0.6),
          width: context.responsiveSize(1.2),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.spa_rounded,
          size: responsiveBadgeSize * 0.55,
          color: AppColors.deepSaffron,
        ),
      ),
    );
  }
}
