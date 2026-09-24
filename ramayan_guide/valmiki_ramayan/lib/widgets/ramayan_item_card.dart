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
  final bool isLocked;

  const RamayanItemCard({
    super.key,
    required this.item,
    required this.languageCode,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  ConsumerState<RamayanItemCard> createState() => _RamayanItemCardState();
}

class _RamayanItemCardState extends ConsumerState<RamayanItemCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref
        .watch(favoritesProvider.notifier)
        .isFavorite(widget.item.id, widget.item.category);

    final previewText = widget.item.description.isNotEmpty
        ? widget.item.description
        : AppStrings.get('read_more', widget.languageCode);

    return TapScaleEffect(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(16.0),
          vertical: context.responsiveSize(6.0),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
          borderRadius: BorderRadius.circular(context.responsiveSize(18.0)),
          border: Border.all(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
            width: context.responsiveSize(1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: context.responsiveSize(6),
              offset: Offset(0, context.responsiveSize(2)),
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
                        fontSize: context.responsiveFontSize(context.isIPad ? 22 : 18.0),
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textLightIvory
                            : AppColors.textDarkBrown,
                      ),
                    ),
                  ),
                  SizedBox(width: context.responsiveSize(8.0)),
                  // if (!widget.isLocked)
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(widget.item);
                      setState(() {});
                    },
                    child: Icon(
                      isFav
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: context.responsiveSize(context.isIPad ? 28 : 24.0),
                      color: isFav
                          ? AppColors.deepSaffron
                          : AppColors.textMutedBrown,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.responsiveSize(8.0)),
              Text(
                formatDescription(previewText),
                maxLines: context.isIPad ? 4 : 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.getStyle(
                  languageCode: widget.languageCode,
                  fontSize: context.responsiveFontSize(context.isIPad ? 18 : 14.0),
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
                  if (widget.isLocked) ...[
                    Icon(
                      Icons.lock_rounded,
                      size: context.responsiveSize(context.isIPad ? 22.0 : 18.0),
                      color: AppColors.deepSaffron,
                    ),
                  ] else ...[
                    Text(
                      AppStrings.get('read_more', widget.languageCode),
                      style: AppTypography.getStyle(
                        languageCode: widget.languageCode,
                        fontSize: context.responsiveFontSize(context.isIPad ? 15 : 13.0),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
