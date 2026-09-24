import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/ramayan_category.dart';
import '../services/context_extensions.dart';
import 'animated_interactions.dart';

class CategoryCard extends StatefulWidget {
  final RamayanCategory category;
  final String languageCode;
  final VoidCallback onTap;
  final double? height;

  const CategoryCard({
    super.key,
    required this.category,
    required this.languageCode,
    required this.onTap,
    this.height,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.category.getLocalizedTitle(widget.languageCode);

    return TapScaleEffect(
      onTap: widget.onTap,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.responsiveSize(20.0)),
          border: Border.all(
            color: AppColors.warmGold.withValues(alpha: isDark ? 0.4 : 0.5),
            width: context.responsiveSize(1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: context.responsiveSize(10),
              offset: Offset(0, context.responsiveSize(4)),
            ),
          ],
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(context.responsiveSize(18.8)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.category.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark
                          ? AppColors.darkCard
                          : AppColors.parchmentCard,
                      child: Icon(
                        widget.category.icon,
                        size: context.responsiveSize(40),
                        color: AppColors.deepSaffron,
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: context.responsiveSize(12.0),
                  right: context.responsiveSize(12.0),
                  bottom: context.responsiveSize(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.getStyle(
                          languageCode: widget.languageCode,
                          fontSize: context.responsiveFontSize(context.isIPad ? 20 : 16),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFF8E8),
                          height: 1.25,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.9),
                              blurRadius: context.responsiveSize(8),
                              offset: Offset(0, context.responsiveSize(2)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
