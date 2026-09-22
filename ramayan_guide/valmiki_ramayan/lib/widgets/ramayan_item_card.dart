import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../constants/util.dart';
import '../models/ramayan_item.dart';
import '../providers/favorites_provider.dart';
import '../services/context_extensions.dart';
import 'animated_interactions.dart';

class RamayanItemCard extends ConsumerStatefulWidget {
  final RamayanItem item;
  final String languageCode;
  final VoidCallback onTap;

  const RamayanItemCard({
    super.key,
    required this.item,
    required this.languageCode,
    required this.onTap,
  });

  @override
  ConsumerState<RamayanItemCard> createState() => _RamayanItemCardState();
}

class _RamayanItemCardState extends ConsumerState<RamayanItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref
        .watch(favoritesProvider.notifier)
        .isFavorite(widget.item.id, widget.item.category);

    final previewText = widget.item.description.isNotEmpty
        ? widget.item.description
        : AppStrings.get('read_more', widget.languageCode);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: TapScaleEffect(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.01 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(16.0),
              vertical: context.responsiveSize(6.0),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
              borderRadius: BorderRadius.circular(context.responsiveSize(18.0)),
              border: Border.all(
                color: _isHovered
                    ? AppColors.warmGold
                    : AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
                width: _isHovered
                    ? context.responsiveSize(1.5)
                    : context.responsiveSize(1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppColors.warmGold.withValues(alpha: isDark ? 0.25 : 0.2)
                      : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: _isHovered
                      ? context.responsiveSize(12)
                      : context.responsiveSize(6),
                  offset: Offset(
                    0,
                    _isHovered
                        ? context.responsiveSize(4)
                        : context.responsiveSize(2),
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(context.responsiveSize(18.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: AppTypography.getStyle(
                            languageCode: widget.languageCode,
                            fontSize: context.responsiveFontSize(18.0),
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textLightIvory
                                : AppColors.textDarkBrown,
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveSize(8.0)),
                      GestureDetector(
                        onTap: () {

                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(widget.item);
                          setState(() {});
                        },
                        child: AnimatedScale(
                          scale: isFav ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            isFav
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: context.responsiveSize(24.0),
                            color: isFav
                                ? AppColors.deepSaffron
                                : AppColors.textMutedBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.responsiveSize(8.0)),
                  Text(
                    formatDescription(previewText),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.getStyle(
                      languageCode: widget.languageCode,
                      fontSize: context.responsiveFontSize(14.0),
                      fontWeight: FontWeight.normal,
                      color: isDark
                          ? AppColors.textMutedIvory
                          : AppColors.textMutedBrown,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(12.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppStrings.get('read_more', widget.languageCode),
                        style: AppTypography.getStyle(
                          languageCode: widget.languageCode,
                          fontSize: context.responsiveFontSize(13.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepSaffron,
                        ),
                      ),
                      SizedBox(width: context.responsiveSize(4.0)),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: context.responsiveSize(16.0),
                        color: AppColors.deepSaffron,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
