import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/ramayan_category.dart';

class CategoryCard extends StatefulWidget {
  final RamayanCategory category;
  final String languageCode;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.languageCode,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.category.getLocalizedTitle(widget.languageCode);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedScale(
            scale: _isHovered ? 1.015 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.warmGold
                      : AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
                  width: _isHovered ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.25)
                        : Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: _isHovered ? 16 : 10,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepSaffron
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                        border: Border.all(
                          color: AppColors.warmGold.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.category.icon,
                        size: 32.0,
                        color: isDark
                            ? AppColors.brightSaffron
                            : AppColors.deepSaffron,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.getStyle(
                        languageCode: widget.languageCode,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textLightIvory
                            : AppColors.textDarkBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
