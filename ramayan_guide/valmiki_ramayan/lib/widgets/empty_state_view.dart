import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../services/context_extensions.dart';
import 'animated_interactions.dart';
import 'diya_painter.dart';

enum EmptyStateType {
  noResults,
  noFavorites,
  comingSoon,
  error,
}

class EmptyStateView extends StatelessWidget {
  final String languageCode;
  final EmptyStateType type;
  final String? customTitle;
  final String? customDesc;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyStateView({
    super.key,
    required this.languageCode,
    this.type = EmptyStateType.noResults,
    this.customTitle,
    this.customDesc,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title;
    String desc;
    IconData icon;

    switch (type) {
      case EmptyStateType.noFavorites:
        title = customTitle ?? AppStrings.get('no_favorites_title', languageCode);
        desc = customDesc ?? AppStrings.get('no_favorites_desc', languageCode);
        icon = Icons.bookmark_border_rounded;
        break;
      case EmptyStateType.comingSoon:
        title = customTitle ?? AppStrings.get('coming_soon_title', languageCode);
        desc = customDesc ?? AppStrings.get('coming_soon_desc', languageCode);
        icon = Icons.auto_awesome_rounded;
        break;
      case EmptyStateType.error:
        title = customTitle ?? AppStrings.get('error_loading_title', languageCode);
        desc = customDesc ?? AppStrings.get('error_loading_desc', languageCode);
        icon = Icons.wifi_off_rounded;
        break;
      case EmptyStateType.noResults:
        title = customTitle ?? AppStrings.get('no_results_title', languageCode);
        desc = customDesc ?? AppStrings.get('no_results_desc', languageCode);
        icon = Icons.search_off_rounded;
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(32.0),
          vertical: context.responsiveSize(48.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StaggeredEntrance(
              index: 0,
              child: Container(
                padding: EdgeInsets.all(context.responsiveSize(20.0)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deepSaffron.withValues(alpha: isDark ? 0.15 : 0.1),
                  border: Border.all(
                    color: AppColors.warmGold.withValues(alpha: 0.4),
                    width: context.responsiveSize(1.5),
                  ),
                ),
                child: type == EmptyStateType.comingSoon
                    ? DiyaWidget(size: context.responsiveSize(48))
                    : Icon(
                        icon,
                        size: context.responsiveSize(44.0),
                        color: isDark ? AppColors.brightSaffron : AppColors.deepSaffron,
                      ),
              ),
            ),
            SizedBox(height: context.responsiveSize(20.0)),
            StaggeredEntrance(
              index: 1,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.getStyle(
                  languageCode: languageCode,
                  fontSize: context.responsiveFontSize(20.0),
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
                ),
              ),
            ),
            SizedBox(height: context.responsiveSize(10.0)),
            StaggeredEntrance(
              index: 2,
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: AppTypography.getStyle(
                  languageCode: languageCode,
                  fontSize: context.responsiveFontSize(14.0),
                  color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
                  height: 1.5,
                ),
              ),
            ),
            if (onActionPressed != null) ...[
              SizedBox(height: context.responsiveSize(24.0)),
              StaggeredEntrance(
                index: 3,
                child: TapScaleEffect(
                  onTap: onActionPressed,
                  child: ElevatedButton.icon(
                    onPressed: onActionPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepSaffron,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveSize(24.0),
                        vertical: context.responsiveSize(12.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.responsiveSize(14.0)),
                      ),
                    ),
                    icon: Icon(
                      type == EmptyStateType.error
                          ? Icons.refresh_rounded
                          : Icons.language_rounded,
                      size: context.responsiveSize(18),
                    ),
                    label: Text(
                      actionLabel ??
                          (type == EmptyStateType.error
                              ? AppStrings.get('retry_btn', languageCode)
                              : AppStrings.get('change_language', languageCode)),
                      style: AppTypography.getStyle(
                        languageCode: languageCode,
                        fontSize: context.responsiveFontSize(14.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
