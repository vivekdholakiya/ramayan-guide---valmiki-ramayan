import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../services/context_extensions.dart';

class FastSearchBar extends StatefulWidget {
  final String languageCode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String initialValue;

  const FastSearchBar({
    super.key,
    required this.languageCode,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.initialValue = '',
  });

  @override
  State<FastSearchBar> createState() => _FastSearchBarState();
}

class _FastSearchBarState extends State<FastSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(16.0),
        vertical: context.responsiveSize(8.0),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
        borderRadius: BorderRadius.circular(context.responsiveSize(16.0)),
        border: Border.all(
          color: AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
          width: context.responsiveSize(1.0),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (val) {
          widget.onChanged(val);
          setState(() {});
        },
        style: AppTypography.getStyle(
          languageCode: widget.languageCode,
          fontSize: context.responsiveFontSize(15.0),
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: context.responsiveSize(24.0),
            color: AppColors.deepSaffron,
          ),
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _controller.text.isNotEmpty
                ? IconButton(
                    key: const ValueKey('clear_btn'),
                    icon: Icon(
                      Icons.clear_rounded,
                      size: context.responsiveSize(20),
                    ),
                    color: AppColors.textMutedBrown,
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      if (widget.onClear != null) widget.onClear!();
                      setState(() {});
                    },
                  )
                : const SizedBox.shrink(key: ValueKey('empty_suffix')),
          ),
          hintText: widget.hintText.isNotEmpty
              ? widget.hintText
              : AppStrings.get('search_placeholder', widget.languageCode),
          hintStyle: AppTypography.getStyle(
            languageCode: widget.languageCode,
            fontSize: context.responsiveFontSize(14.0),
            color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: context.responsiveSize(14.0),
          ),
        ),
      ),
    );
  }
}
