import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/status_item.dart';
import '../providers/offline_provider.dart';
import '../services/context_extensions.dart';

/// StatusCard renders a premium 9:16 devotional quote card.
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
                borderRadius: BorderRadius.circular(context.responsiveSize(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: context.responsiveSize(20),
                    offset: Offset(0, context.responsiveSize(8)),
                  ),
                ],
              )
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.responsiveSize(20)),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background Image ─────────────────────────────────────
                _BackgroundImage(imageUrl: item.imageUrl),

                // ── Gradient Overlays ────────────────────────────────────
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
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveSize(24),
                        vertical: context.responsiveSize(60),
                      ),
                      child: _QuoteContent(item: item),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────

class _BackgroundImage extends ConsumerWidget {
  final String imageUrl;

  const _BackgroundImage({required this.imageUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return _buildFallback(context);
    }

    final localFileAsync = ref.watch(localImageFileProvider(imageUrl));

    return localFileAsync.when(
      data: (file) {
        if (file != null && file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildNetworkImage(context),
          );
        }
        return _buildNetworkImage(context);
      },
      loading: () => _buildNetworkImage(context),
      error: (error, stackTrace) => _buildNetworkImage(context),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingPlaceholder(context);
      },
      errorBuilder: (context, error, stackTrace) => _buildFallback(context),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
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
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.warmGold,
          strokeWidth: context.responsiveSize(2),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
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
              size: context.responsiveSize(80),
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
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(16),
          vertical: context.responsiveSize(6),
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(context.responsiveSize(20)),
          border: Border.all(
            color: AppColors.warmGold.withValues(alpha: 0.5),
            width: context.responsiveSize(0.8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_rounded,
              size: context.responsiveSize(12),
              color: AppColors.warmGold.withValues(alpha: 0.9),
            ),
            SizedBox(width: context.responsiveSize(6)),
            Text(
              'Ramayana Guide: Valmiki Ramayana',
              style: AppTypography.getStyle(
                languageCode: 'en',
                fontSize: context.responsiveFontSize(11),
                fontWeight: FontWeight.w600,
                color: AppColors.warmGold.withValues(alpha: 0.9),
                height: 1.2,
              ),
            ),
            SizedBox(width: context.responsiveSize(6)),
            Icon(
              Icons.spa_rounded,
              size: context.responsiveSize(12),
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

    double fontSize;
    if (charCount < 60) {
      fontSize = context.responsiveFontSize(22);
    } else if (charCount < 100) {
      fontSize = context.responsiveFontSize(19);
    } else if (charCount < 150) {
      fontSize = context.responsiveFontSize(17);
    } else {
      fontSize = context.responsiveFontSize(15);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _GoldenOrnament(),

        SizedBox(height: context.responsiveSize(12)),

        Text(
          '❝  $quoteText  ❞',
          textAlign: TextAlign.center,
          style: AppTypography.getStyle(
            languageCode: 'gu',
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFF8E8),
            height: 1.65,
          ).copyWith(
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: context.responsiveSize(12),
                offset: Offset(0, context.responsiveSize(2)),
              ),
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: context.responsiveSize(6),
              ),
            ],
          ),
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: context.responsiveSize(14)),

        _GoldenDivider(),

        SizedBox(height: context.responsiveSize(14)),

        const _TopBadge(),
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
          width: context.responsiveSize(32),
          height: context.responsiveSize(1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warmGold.withValues(alpha: 0.0),
                AppColors.warmGold.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        SizedBox(width: context.responsiveSize(8)),
        Icon(
          Icons.brightness_7_rounded,
          size: context.responsiveSize(14),
          color: AppColors.warmGold.withValues(alpha: 0.9),
        ),
        SizedBox(width: context.responsiveSize(6)),
        Text(
          '॥',
          style: TextStyle(
            color: AppColors.warmGold.withValues(alpha: 0.9),
            fontSize: context.responsiveFontSize(16),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: context.responsiveSize(6)),
        Icon(
          Icons.brightness_7_rounded,
          size: context.responsiveSize(14),
          color: AppColors.warmGold.withValues(alpha: 0.9),
        ),
        SizedBox(width: context.responsiveSize(8)),
        Container(
          width: context.responsiveSize(32),
          height: context.responsiveSize(1),
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
            height: context.responsiveSize(0.8),
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
          padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(8)),
          child: Icon(
            Icons.spa_rounded,
            size: context.responsiveSize(12),
            color: AppColors.warmGold.withValues(alpha: 0.7),
          ),
        ),
        Expanded(
          child: Container(
            height: context.responsiveSize(0.8),
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
