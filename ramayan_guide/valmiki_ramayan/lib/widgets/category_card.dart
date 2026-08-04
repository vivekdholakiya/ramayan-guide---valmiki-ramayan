import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/ramayan_category.dart';

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
            scale: _isHovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.warmGold
                      : AppColors.warmGold.withValues(alpha: isDark ? 0.4 : 0.5),
                  width: _isHovered ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? AppColors.warmGold.withValues(alpha: isDark ? 0.35 : 0.3)
                        : Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                    blurRadius: _isHovered ? 16 : 10,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ── Category Image Asset ──────────────────────────────
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
                            size: 40,
                            color: AppColors.deepSaffron,
                          ),
                        );
                      },
                    ),

                    // ── Gradient Overlay for Text Readability ─────────────
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

                    // ── Category Title & Accent ────────────────────────────
                    Positioned(
                      left: 12.0,
                      right: 12.0,
                      bottom: 12.0,
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
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFF8E8), // Warm Ivory
                              height: 1.25,
                            ).copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.9),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
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
          ),
        ),
      ),
    );
  }
}
