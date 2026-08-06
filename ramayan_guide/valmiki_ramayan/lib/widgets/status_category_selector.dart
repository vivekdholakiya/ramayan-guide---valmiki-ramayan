import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/status_category.dart';
import '../services/context_extensions.dart';

/// StatusCategorySelector displays a horizontally scrollable row of filter chips.
class StatusCategorySelector extends StatelessWidget {
  final List<StatusCategory> categories;
  final String selectedCategoryId; // '' = All
  final ValueChanged<String> onCategorySelected;
  final String languageCode;

  const StatusCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: context.responsiveSize(48),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.parchmentLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.2 : 0.3),
            width: context.responsiveSize(0.8),
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(12),
          vertical: context.responsiveSize(6),
        ),
        children: [
          _CategoryChip(
            label: _allLabel(languageCode),
            isSelected: selectedCategoryId.isEmpty,
            isDark: isDark,
            onTap: () => onCategorySelected(''),
          ),
          ...categories.map((cat) => _CategoryChip(
                label: cat.name,
                isSelected: selectedCategoryId == cat.id,
                isDark: isDark,
                onTap: () => onCategorySelected(cat.id),
              )),
        ],
      ),
    );
  }

  String _allLabel(String langCode) {
    switch (langCode) {
      case 'gu':
        return 'બધા';
      case 'hi':
        return 'सभी';
      default:
        return 'All';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: context.responsiveSize(8)),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSize(14),
            vertical: context.responsiveSize(5),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.deepSaffron
                : (isDark
                    ? AppColors.darkCard
                    : AppColors.parchmentCard),
            borderRadius: BorderRadius.circular(context.responsiveSize(20)),
            border: Border.all(
              color: isSelected
                  ? AppColors.deepSaffron
                  : AppColors.warmGold
                      .withValues(alpha: isDark ? 0.3 : 0.45),
              width: isSelected ? 0 : context.responsiveSize(1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.deepSaffron.withValues(alpha: 0.35),
                      blurRadius: context.responsiveSize(8),
                      offset: Offset(0, context.responsiveSize(2)),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.getStyle(
                languageCode: 'gu',
                fontSize: context.responsiveFontSize(13),
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textMutedIvory
                        : AppColors.textMutedBrown),
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
