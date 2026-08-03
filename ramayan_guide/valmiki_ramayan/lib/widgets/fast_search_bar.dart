import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.warmGold.withValues(alpha: isDark ? 0.3 : 0.4),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: AppTypography.getStyle(
          languageCode: widget.languageCode,
          fontSize: 15.0,
          color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.deepSaffron,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  color: AppColors.textMutedBrown,
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    if (widget.onClear != null) widget.onClear!();
                    setState(() {});
                  },
                )
              : null,
          hintText: widget.hintText.isNotEmpty
              ? widget.hintText
              : AppStrings.get('search_placeholder', widget.languageCode),
          hintStyle: AppTypography.getStyle(
            languageCode: widget.languageCode,
            fontSize: 14.0,
            color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }
}
