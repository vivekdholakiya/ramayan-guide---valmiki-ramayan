import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/status_item.dart';

/// StatusCard renders a premium 9:16 devotional quote card.
///
/// Displays:
///  - Full background image (BoxFit.cover)
///  - Dark gradient overlay at the bottom for readability
///  - Gujarati quote text (auto-sized by length, centered)
///  - Decorative golden divider
///  - Subtle attribution line ("॥ શ્રી રામ ॥")
///
/// Designed to match the existing app's spiritual aesthetic using
/// AppColors and AppTypography conventions.
class StatusCard extends StatelessWidget {
  final StatusItem item;
  final VoidCallback? onTap;
  final bool showShadow;

  const StatusCard({
    super.key,
    required this.item,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: showShadow
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              )
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background Image ─────────────────────────────────────
                _BackgroundImage(imageUrl: item.imageUrl),

                // ── Gradient Overlays ────────────────────────────────────
                // Top vignette (subtle, keeps top area usable)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: const Alignment(0, -0.3),
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Full-card radial overlay — darkens center for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.9,
                      colors: [
                        Colors.black.withValues(alpha: 0.40),
                        Colors.black.withValues(alpha: 0.40),
                        Colors.black.withValues(alpha: 0.08),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),

                // ── Quote Content (centered) ─────────────────────────────
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 60),
                      child: _QuoteContent(item: item),
                    ),
                  ),
                ),

                // ── Top decorative badge ─────────────────────────────────

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────

class _BackgroundImage extends StatelessWidget {
  final String imageUrl;

  const _BackgroundImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B1A08),
            Color(0xFF1A0C04),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.warmGold,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A1A06),
            Color(0xFF1A0C04),
            Color(0xFF2C1208),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 80,
              color: AppColors.warmGold.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  const _TopBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.warmGold.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_rounded,
              size: 12,
              color: AppColors.warmGold.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 6),
            Text(
              'VD\'S Valmiki Ramayan App',
              style: AppTypography.getStyle(
                languageCode: 'en',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.warmGold.withValues(alpha: 0.9),
                height: 1.2,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.spa_rounded,
              size: 12,
              color: AppColors.warmGold.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteContent extends StatelessWidget {
  final StatusItem item;

  const _QuoteContent({required this.item});

  @override
  Widget build(BuildContext context) {
    final quoteText = item.quote.text;
    final charCount = quoteText.length;

    // Adaptive font size based on quote length
    double fontSize;
    if (charCount < 60) {
      fontSize = 22;
    } else if (charCount < 100) {
      fontSize = 19;
    } else if (charCount < 150) {
      fontSize = 17;
    } else {
      fontSize = 15;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
        children: [
          // ── Decorative top ornament ──────────────────────────────────
          _GoldenOrnament(),

          const SizedBox(height: 12),

          // ── Quote text ───────────────────────────────────────────────
          Text(
            '❝  $quoteText  ❞',
            textAlign: TextAlign.center,
            style: AppTypography.getStyle(
              languageCode: 'gu',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFF8E8), // warm ivory
              height: 1.65,
            ).copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // ── Decorative divider ───────────────────────────────────────
          _GoldenDivider(),

          const SizedBox(height: 14),

          _TopBadge(),


        ],
    );
  }
}

class _GoldenOrnament extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warmGold.withValues(alpha: 0.0),
                AppColors.warmGold.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.brightness_7_rounded,
          size: 14,
          color: AppColors.warmGold.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 6),
        Text(
          '॥',
          style: TextStyle(
            color: AppColors.warmGold.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.brightness_7_rounded,
          size: 14,
          color: AppColors.warmGold.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warmGold.withValues(alpha: 0.8),
                AppColors.warmGold.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GoldenDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warmGold.withValues(alpha: 0.0),
                  AppColors.warmGold.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.spa_rounded,
            size: 12,
            color: AppColors.warmGold.withValues(alpha: 0.7),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warmGold.withValues(alpha: 0.6),
                  AppColors.warmGold.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

