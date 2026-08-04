import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/status_category.dart';

/// StatusCategorySelector displays a horizontally scrollable row of filter chips.
///
/// - First chip is always "બધા" (All)
/// - Remaining chips are dynamically loaded from Firebase categories
/// - Selected chip uses saffron background matching the existing app style
/// - Unselected chips use parchment/dark card surface with gold border
///
/// Height is kept compact (~44px) to not compete with the status cards.
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
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.parchmentLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.2 : 0.3),
            width: 0.8,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          // "All" chip
          _CategoryChip(
            label: _allLabel(languageCode),
            isSelected: selectedCategoryId.isEmpty,
            isDark: isDark,
            onTap: () => onCategorySelected(''),
          ),
          // Dynamic category chips
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
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.deepSaffron
                : (isDark
                    ? AppColors.darkCard
                    : AppColors.parchmentCard),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.deepSaffron
                  : AppColors.warmGold
                      .withValues(alpha: isDark ? 0.3 : 0.45),
              width: isSelected ? 0 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.deepSaffron.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.getStyle(
                languageCode: 'gu',
                fontSize: 13,
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
