import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../constants/util.dart';
import '../models/app_settings.dart';
import '../models/ramayan_category.dart';
import '../models/ramayan_item.dart';
import '../providers/favorites_provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/history_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/diya_painter.dart';
import '../widgets/responsive_container.dart';
import '../widgets/spiritual_decorations.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final RamayanItem item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(historyProvider.notifier).recordView(widget.item);
    });
  }

  void _shareItem(BuildContext context, String langCode) {
    final title = widget.item.title;
    final categoryName = RamayanCategory.findById(widget.item.category)
            ?.getLocalizedTitle(langCode) ??
        widget.item.category;
    final text =
        '🚩 *$title* ($categoryName)\n\n${widget.item.description}\n\n- ${AppStrings.get('share_text', langCode)}';

    try {
      Share.share(text);
    } catch (_) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('link_copied', langCode)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final fontSizeOption = ref.watch(fontSizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref.watch(favoritesProvider.notifier).isFavorite(
          widget.item.id,
          widget.item.category,
        );

    final categoryObj = RamayanCategory.findById(widget.item.category);
    final categoryTitle = categoryObj?.getLocalizedTitle(language.code) ??
        widget.item.category;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryTitle,
          style: AppTypography.getStyle(
            languageCode: language.code,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
          ),
        ),
        actions: [
          // Bookmark / Favorite Toggle
          IconButton(
            icon: Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isFav ? AppColors.deepSaffron : null,
            ),
            tooltip: AppStrings.get('nav_favorites', language.code),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(widget.item);
            },
          ),
          // Share Button
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share',
            onPressed: () => _shareItem(context, language.code),
          ),
          // Font Size Selector Shortcut
          PopupMenuButton<AppFontSize>(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: AppStrings.get('settings_font_size', language.code),
            onSelected: (size) {
              ref.read(fontSizeProvider.notifier).setFontSize(size);
            },
            itemBuilder: (context) => AppFontSize.values.map((fSize) {
              return PopupMenuItem<AppFontSize>(
                value: fSize,
                child: Row(
                  children: [
                    if (fSize == fontSizeOption)
                      const Icon(Icons.check_rounded,
                          color: AppColors.deepSaffron, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(AppStrings.get('font_${fSize.key}', language.code)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          // maxWidth: 760.0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: AppColors.warmGold.withValues(alpha: isDark ? 0.35 : 0.45),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spiritual Header Motif
                  const DiyaWidget(size: 36),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.item.title,
                    textAlign: TextAlign.center,
                    style: AppTypography.getStyle(
                      languageCode: language.code,
                      fontSize: fontSizeOption.bodyFontSize + 8.0,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textLightIvory
                          : AppColors.textDarkBrown,
                      height: 1.3,
                    ),
                  ),
                  const MandalaDivider(),
                  // Stored Firestore description displayed strictly as-is
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(
                      formatDescription(widget.item.description),
                      textAlign: TextAlign.justify,
                      style: AppTypography.getStyle(
                        languageCode: language.code,
                        fontSize: fontSizeOption.bodyFontSize,
                        fontWeight: FontWeight.normal,
                        color: isDark
                            ? AppColors.textLightIvory
                            : AppColors.textDarkBrown,
                        height: fontSizeOption.lineHeight,
                      ),
                    )
                  ),
                  // const SizedBox(height: 24),
                  const MandalaDivider(),
                  const SizedBox(height: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
