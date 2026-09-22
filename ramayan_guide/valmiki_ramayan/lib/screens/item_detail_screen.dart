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
import '../services/context_extensions.dart';
import '../widgets/animated_interactions.dart';
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
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      Share.share(text, sharePositionOrigin: origin);
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
          icon: Icon(
            Icons.arrow_back_rounded,
            size: context.responsiveSize(24),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryTitle,
          style: AppTypography.getStyle(
            languageCode: language.code,
            fontSize: context.responsiveFontSize(18),
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedScale(
              scale: isFav ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: context.responsiveSize(24),
                color: isFav ? AppColors.deepSaffron : null,
              ),
            ),
            tooltip: AppStrings.get('nav_favorites', language.code),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(widget.item);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              size: context.responsiveSize(24),
            ),
            tooltip: 'Share',
            onPressed: () => _shareItem(context, language.code),
          ),
          PopupMenuButton<AppFontSize>(
            icon: Icon(
              Icons.format_size_rounded,
              size: context.responsiveSize(24),
            ),
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
                      Icon(
                        Icons.check_rounded,
                        color: AppColors.deepSaffron,
                        size: context.responsiveSize(18),
                      )
                    else
                      SizedBox(width: context.responsiveSize(18)),
                    SizedBox(width: context.responsiveSize(8)),
                    Text(
                      AppStrings.get('font_${fSize.key}', language.code),
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(width: context.responsiveSize(8)),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: context.isIPad ? 780.0 : 1280.0,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.isIPad
                  ? context.responsiveSize(24.0)
                  : context.responsiveSize(12.0),
              vertical: context.responsiveSize(20.0),
            ),
            child: StaggeredEntrance(
              index: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(12.0),
                  vertical: context.responsiveSize(20.0),
                ),                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                  borderRadius: BorderRadius.circular(context.responsiveSize(24.0)),
                  border: Border.all(
                    color: AppColors.warmGold.withValues(alpha: isDark ? 0.35 : 0.45),
                    width: context.responsiveSize(1.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                      blurRadius: context.responsiveSize(16),
                      offset: Offset(0, context.responsiveSize(4)),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StaggeredEntrance(
                      index: 1,
                      child: DiyaWidget(size: context.responsiveSize(36)),
                    ),
                    SizedBox(height: context.responsiveSize(16)),
                    StaggeredEntrance(
                      index: 2,
                      child: Text(
                        widget.item.title,
                        textAlign: TextAlign.center,
                        style: AppTypography.getStyle(
                          languageCode: language.code,
                          fontSize: context.responsiveFontSize(fontSizeOption.bodyFontSize + 8.0),
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textLightIvory
                              : AppColors.textDarkBrown,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const MandalaDivider(),
                    StaggeredEntrance(
                      index: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(
                          formatDescription(widget.item.description),
                          textAlign: TextAlign.justify,
                          style: AppTypography.getStyle(
                            languageCode: language.code,
                            fontSize: context.responsiveFontSize(fontSizeOption.bodyFontSize),
                            fontWeight: FontWeight.normal,
                            color: isDark
                                ? AppColors.textLightIvory
                                : AppColors.textDarkBrown,
                            height: fontSizeOption.lineHeight,
                          ),
                        ),
                      ),
                    ),
                    const MandalaDivider(),
                    SizedBox(height: context.responsiveSize(0)),
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
