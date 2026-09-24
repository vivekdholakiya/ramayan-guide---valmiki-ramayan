import 'dart:io';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../constants/util.dart';
import '../models/status_item.dart';
import '../providers/language_provider.dart';
import '../services/ads.dart';
import '../services/context_extensions.dart';
import '../widgets/status_card.dart';

/// Full-screen immersive status viewer.
class StatusViewerScreen extends ConsumerStatefulWidget {
  final List<StatusItem> items;
  final int initialIndex;

  const StatusViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  ConsumerState<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends ConsumerState<StatusViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _uiAnimController;
  late Animation<double> _uiFadeAnimation;
  bool _showUI = true;
  bool _isSharing = false;

  late List<GlobalKey> _repaintKeys;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _uiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _uiFadeAnimation = CurvedAnimation(
      parent: _uiAnimController,
      curve: Curves.easeInOut,
    );
    _uiAnimController.forward();

    _repaintKeys = List.generate(widget.items.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiAnimController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiAnimController.forward();
    } else {
      _uiAnimController.reverse();
    }
  }

  Future<void> _shareStatus() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    try {
      final key = _repaintKeys[_currentIndex];
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        setState(() => _isSharing = false);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file =
          File('${tempDir.path}/ramayan_status_${_currentIndex + 1}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: appUrl,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      debugPrint('[StatusViewer] Share error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _onShareWithAd() {
    final language = ref.read(languageProvider);
    adsControllerVar.showRewardedAd(
      context,
      title: AppStrings.get('ad_unlock_status_title', language.code),
      description: AppStrings.get('ad_unlock_status_desc', language.code),
      watchButtonText: AppStrings.get('ad_watch_btn', language.code),
      maybeLaterText: AppStrings.get('ad_maybe_later_btn', language.code),
      onRewardGranted: () {
        _shareStatus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                if (!_showUI) {
                  setState(() => _showUI = true);
                  _uiAnimController.forward();
                }
              },
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: context.responsiveSize(16),
                      right: context.responsiveSize(16),
                      top: context.responsiveSize(50),
                      bottom: context.responsiveSize(16),
                    ),
                    child: Center(
                      child: RepaintBoundary(
                        key: _repaintKeys[index],
                        child: StatusCard(
                          item: item,
                          showShadow: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _uiFadeAnimation,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveSize(8),
                      vertical: context.responsiveSize(4),
                    ),
                    child: Row(
                      children: [
                        _GlassButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        _PageIndicatorLabel(
                          current: _currentIndex + 1,
                          total: widget.items.length,
                          languageCode: language.code,
                        ),
                        const Spacer(),
                        _GlassButton(
                          icon: _isSharing
                              ? Icons.hourglass_top_rounded
                              : Icons.share_rounded,
                          onTap: _onShareWithAd,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _uiFadeAnimation,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: context.responsiveSize(16)),
                    child: _PageDots(
                      count: widget.items.length,
                      current: _currentIndex,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdsBannerWidget(),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.responsiveSize(40),
        height: context.responsiveSize(40),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: context.responsiveSize(0.8),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: context.responsiveSize(20),
        ),
      ),
    );
  }
}

class _PageIndicatorLabel extends StatelessWidget {
  final int current;
  final int total;
  final String languageCode;

  const _PageIndicatorLabel({
    required this.current,
    required this.total,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(12),
        vertical: context.responsiveSize(5),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
        border: Border.all(
          color: AppColors.warmGold.withValues(alpha: 0.3),
          width: context.responsiveSize(0.8),
        ),
      ),
      child: Text(
        '$current / $total',
        style: AppTypography.getStyle(
          languageCode: languageCode,
          fontSize: context.responsiveFontSize(12),
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
          height: 1.2,
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    if (count > 12) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: context.responsiveSize(3)),
          width: isActive ? context.responsiveSize(18) : context.responsiveSize(6),
          height: context.responsiveSize(6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.warmGold
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(context.responsiveSize(3)),
          ),
        );
      }),
    );
  }
}
