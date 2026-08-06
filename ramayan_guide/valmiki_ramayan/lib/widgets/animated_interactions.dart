import 'package:flutter/material.dart';

/// TapScaleEffect provides a subtle, premium press feedback (1.0 -> 0.97 -> 1.0)
/// for interactive cards, buttons, and touchable elements.
class TapScaleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;

  const TapScaleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.97,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<TapScaleEffect> createState() => _TapScaleEffectState();
}

class _TapScaleEffectState extends State<TapScaleEffect> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// StaggeredEntrance provides a calm, progressive entrance animation (Fade + slight upward slide + subtle scale)
/// for cards, list items, grid cells, and section headers.
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delayStep;
  final Offset slideOffset;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 350),
    this.delayStep = const Duration(milliseconds: 40),
    this.slideOffset = const Offset(0.0, 0.05),
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    final delayMilliseconds = (widget.index * widget.delayStep.inMilliseconds).clamp(0, 250);
    Future.delayed(Duration(milliseconds: delayMilliseconds), () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : widget.slideOffset,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isVisible ? 1.0 : 0.97,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// SpiritualPageTransitionsBuilder renders a calm, peaceful fade + subtle scale/slide
/// page transition for Android & iOS screen navigation.
class SpiritualPageTransitionsBuilder extends PageTransitionsBuilder {
  const SpiritualPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.04, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      ),
    );
  }
}
