import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:valmiki_ramayan/constants/util.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/status_item.dart';
import '../providers/offline_provider.dart';
import '../providers/status_provider.dart';
import '../screens/status_viewer_screen.dart';
import '../services/context_extensions.dart';
import '../widgets/status_card.dart';

/// HeroBanner — Daily Quote ("આજનો વિચાર") section on the Home Screen.
class HeroBanner extends ConsumerStatefulWidget {
  final String languageCode;

  const HeroBanner({
    super.key,
    required this.languageCode,
  });

  @override
  ConsumerState<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends ConsumerState<HeroBanner>
    with WidgetsBindingObserver {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;

  late int _lastDayIndex;

  @override
  void initState() {
    super.initState();
    _lastDayIndex = _dayIndex();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final today = _dayIndex();
      if (today != _lastDayIndex) {
        _lastDayIndex = today;
        ref.invalidate(dailyQuoteProvider(widget.languageCode));
      }
    }
  }

  int _dayIndex() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(DateTime(2020, 1, 1)).inDays;
  }

  Future<void> _share(DailyQuoteSelection selection) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        setState(() => _isSharing = false);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/ramayan_daily_quote_${_dayIndex()}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: appUrl,
      );
    } catch (e) {
      debugPrint('[HeroBanner] Share error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _openViewer(DailyQuoteSelection selection) {
    final statusItem = StatusItem(
      quote: selection.quote,
      imageUrl: selection.imageUrl,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatusViewerScreen(
          items: [statusItem],
          initialIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyAsync =
        ref.watch(dailyQuoteProvider(widget.languageCode));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(16.0),
        vertical: context.responsiveSize(12.0),
      ),
      child: dailyAsync.when(
        data: (selection) {
          if (selection == null) {
            return _EmptyBanner(
              languageCode: widget.languageCode,
              isDark: isDark,
            );
          }

          final statusItem = StatusItem(
            quote: selection.quote,
            imageUrl: selection.imageUrl,
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Off-screen 9:16 StatusCard for high-res status sharing
              Positioned(
                left: -9999,
                top: -9999,
                child: SizedBox(
                  width: context.responsiveSize(540),
                  height: context.responsiveSize(960),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: StatusCard(
                      item: statusItem,
                      showShadow: false,
                    ),
                  ),
                ),
              ),

              // Visible Home Screen Daily Quote Banner
              GestureDetector(
                onTap: () => _openViewer(selection),
                child: _DailyQuoteCard(
                  selection: selection,
                  languageCode: widget.languageCode,
                  isDark: isDark,
                  isSharing: _isSharing,
                  onShare: () => _share(selection),
                ),
              ),
            ],
          );
        },
        loading: () => _ShimmerBanner(isDark: isDark),
        error: (_, error) => _EmptyBanner(
          languageCode: widget.languageCode,
          isDark: isDark,
          isError: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Quote Card
// ─────────────────────────────────────────────────────────────────────────────

class _DailyQuoteCard extends StatelessWidget {
  final DailyQuoteSelection selection;
  final String languageCode;
  final bool isDark;
  final bool isSharing;
  final VoidCallback onShare;

  const _DailyQuoteCard({
    required this.selection,
    required this.languageCode,
    required this.isDark,
    required this.isSharing,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.responsiveSize(24)),
      child: Stack(
        children: [
          // ── Background Image ─────────────────────────────────────────
          _BannerImage(imageUrl: selection.imageUrl),

          // ── Dark overlay — top vignette ──────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0, 0.2),
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Dark overlay — bottom half ───────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: const Alignment(0, 0.0),
                  colors: [
                    Colors.black.withValues(alpha: 0.90),
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.25, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Quote content ────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _QuoteContent(
              selection: selection,
              languageCode: languageCode,
              isSharing: isSharing,
              onShare: onShare,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background image ──────────────────────────────────────────────────────

class _BannerImage extends ConsumerWidget {
  final String imageUrl;

  const _BannerImage({required this.imageUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) return _fallback(context);

    final localFileAsync = ref.watch(localImageFileProvider(imageUrl));

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: localFileAsync.when(
        data: (file) {
          if (file != null && file.existsSync()) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => _buildNetworkImage(context),
            );
          }
          return _buildNetworkImage(context);
        },
        loading: () => _buildNetworkImage(context),
        error: (error, stackTrace) => _buildNetworkImage(context),
      ),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _fallback(context);
      },
      errorBuilder: (context, error, stackTrace) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B1A08),
              Color(0xFF1A0A04),
              Color(0xFF2C1208),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.spa_rounded,
            size: context.responsiveSize(56),
            color: AppColors.warmGold.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }
}

// ── Quote content block ───────────────────────────────────────────────────

class _QuoteContent extends StatelessWidget {
  final DailyQuoteSelection selection;
  final String languageCode;
  final bool isSharing;
  final VoidCallback onShare;

  const _QuoteContent({
    required this.selection,
    required this.languageCode,
    required this.isSharing,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final text = selection.quote.text;
    final category = selection.quote.category;
    final charCount = text.length;

    double fontSize;
    if (charCount < 60) {
      fontSize = context.responsiveFontSize(20);
    } else if (charCount < 100) {
      fontSize = context.responsiveFontSize(17);
    } else if (charCount < 150) {
      fontSize = context.responsiveFontSize(15);
    } else {
      fontSize = context.responsiveFontSize(13);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(20),
        0,
        context.responsiveSize(20),
        context.responsiveSize(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _GoldenRow(),

          SizedBox(height: context.responsiveSize(10)),

          Text(
            '❝  $text  ❞',
            textAlign: TextAlign.center,
            style: AppTypography.getStyle(
              languageCode: languageCode,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFF8E8),
              height: 1.7,
            ).copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.85),
                  blurRadius: context.responsiveSize(10),
                  offset: Offset(0, context.responsiveSize(2)),
                ),
              ],
            ),
            maxLines: 7,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: context.responsiveSize(12)),

          _GoldenDivider(),

          SizedBox(height: context.responsiveSize(10)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (category.isNotEmpty)
                Flexible(
                  child: Text(
                    '- $category',
                    style: AppTypography.getStyle(
                      languageCode: languageCode,
                      fontSize: context.responsiveFontSize(12),
                      fontWeight: FontWeight.w500,
                      color:
                          AppColors.warmGold.withValues(alpha: 0.80),
                      height: 1.4,
                    ).copyWith(letterSpacing: 0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const SizedBox.shrink(),

              _ShareButton(
                isSharing: isSharing,
                onTap: onShare,
                languageCode: languageCode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Share button ──────────────────────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  final bool isSharing;
  final VoidCallback onTap;
  final String languageCode;

  const _ShareButton({
    required this.isSharing,
    required this.onTap,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSharing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(14),
          vertical: context.responsiveSize(7),
        ),
        decoration: BoxDecoration(
          color: isSharing
              ? AppColors.deepSaffron.withValues(alpha: 0.5)
              : AppColors.deepSaffron,
          borderRadius: BorderRadius.circular(context.responsiveSize(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepSaffron.withValues(alpha: 0.4),
              blurRadius: context.responsiveSize(10),
              offset: Offset(0, context.responsiveSize(3)),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSharing
                  ? Icons.hourglass_top_rounded
                  : Icons.share_rounded,
              size: context.responsiveSize(14),
              color: Colors.white,
            ),
            SizedBox(width: context.responsiveSize(6)),
            Text(
              AppStrings.get('share', languageCode),
              style: AppTypography.getStyle(
                languageCode: languageCode,
                fontSize: context.responsiveFontSize(12),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Decorative helpers ────────────────────────────────────────────────────

class _GoldenRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _fadeLine(context: context, toRight: false),
        SizedBox(width: context.responsiveSize(8)),
        Icon(
          Icons.brightness_7_rounded,
          size: context.responsiveSize(13),
          color: AppColors.warmGold.withValues(alpha: 0.85),
        ),
        SizedBox(width: context.responsiveSize(5)),
        Text(
          '॥',
          style: TextStyle(
            color: AppColors.warmGold.withValues(alpha: 0.9),
            fontSize: context.responsiveFontSize(15),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: context.responsiveSize(5)),
        Icon(
          Icons.brightness_7_rounded,
          size: context.responsiveSize(13),
          color: AppColors.warmGold.withValues(alpha: 0.85),
        ),
        SizedBox(width: context.responsiveSize(8)),
        _fadeLine(context: context, toRight: true),
      ],
    );
  }

  Widget _fadeLine({required BuildContext context, required bool toRight}) {
    return Container(
      width: context.responsiveSize(28),
      height: context.responsiveSize(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: toRight
              ? [
                  AppColors.warmGold.withValues(alpha: 0.7),
                  AppColors.warmGold.withValues(alpha: 0.0),
                ]
              : [
                  AppColors.warmGold.withValues(alpha: 0.0),
                  AppColors.warmGold.withValues(alpha: 0.7),
                ],
        ),
      ),
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
            height: context.responsiveSize(0.7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warmGold.withValues(alpha: 0.0),
                  AppColors.warmGold.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(8)),
          child: Icon(
            Icons.spa_rounded,
            size: context.responsiveSize(11),
            color: AppColors.warmGold.withValues(alpha: 0.65),
          ),
        ),
        Expanded(
          child: Container(
            height: context.responsiveSize(0.7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warmGold.withValues(alpha: 0.55),
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

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerBanner extends StatelessWidget {
  final bool isDark;

  const _ShimmerBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor = isDark
        ? AppColors.shimmerHighlightDark
        : AppColors.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(context.responsiveSize(24)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyBanner extends StatelessWidget {
  final String languageCode;
  final bool isDark;
  final bool isError;

  const _EmptyBanner({
    required this.languageCode,
    required this.isDark,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.responsiveSize(24)),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2E1A0C), const Color(0xFF1F1007)]
                : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.warmGold.withValues(alpha: 0.35),
            width: context.responsiveSize(1.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.cloud_off_rounded : Icons.spa_rounded,
              size: context.responsiveSize(36),
              color: AppColors.warmGold.withValues(alpha: 0.5),
            ),
            SizedBox(height: context.responsiveSize(12)),
            Text(
              AppStrings.get('daily_quote_unavailable', languageCode),
              textAlign: TextAlign.center,
              style: AppTypography.getStyle(
                languageCode: languageCode,
                fontSize: context.responsiveFontSize(14),
                color: isDark
                    ? AppColors.textMutedIvory
                    : AppColors.textMutedBrown,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
