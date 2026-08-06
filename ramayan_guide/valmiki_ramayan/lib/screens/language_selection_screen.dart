import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';
import '../widgets/animated_interactions.dart';
import '../widgets/diya_painter.dart';
import '../widgets/responsive_container.dart';
import 'home_screen.dart';

/// LanguageInfo holds display metadata for supported languages.
class LanguageInfo {
  final AppLanguage language;
  final String nativeName;
  final String englishName;

  const LanguageInfo({
    required this.language,
    required this.nativeName,
    required this.englishName,
  });
}

const List<LanguageInfo> _supportedLanguagesInfo = [
  LanguageInfo(
    language: AppLanguage.gu,
    nativeName: 'ગુજરાતી',
    englishName: 'Gujarati',
  ),
  LanguageInfo(
    language: AppLanguage.hi,
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
  ),
  LanguageInfo(
    language: AppLanguage.en,
    nativeName: 'English',
    englishName: 'English',
  ),
];

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  final bool isFromSettings;

  const LanguageSelectionScreen({
    super.key,
    this.isFromSettings = false,
  });

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  late AppLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = ref.read(languageProvider);
  }

  void _onConfirmLanguage() async {
    await ref.read(languageProvider.notifier).setLanguage(_selectedLanguage);

    if (!mounted) return;

    if (widget.isFromSettings) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLangCode = _selectedLanguage.code;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.parchmentLight;
    final cardBg = isDark ? AppColors.darkCard : AppColors.parchmentCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.parchmentBorder;
    final textColor = isDark ? AppColors.textLightIvory : AppColors.textDarkBrown;
    final mutedTextColor = isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.isFromSettings
          ? AppBar(
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: context.responsiveSize(24),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(
                AppStrings.get('settings_language', currentLangCode),
                style: AppTypography.getStyle(
                  languageCode: currentLangCode,
                  fontSize: context.responsiveFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
            maxWidth: 560.0,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(24.0),
                vertical: context.responsiveSize(20.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!widget.isFromSettings) SizedBox(height: context.responsiveSize(20)),

                  StaggeredEntrance(
                    index: 0,
                    child: Container(
                      padding: EdgeInsets.all(context.responsiveSize(22.0)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepSaffron.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.warmGold,
                          width: context.responsiveSize(1.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepSaffron.withValues(alpha: isDark ? 0.2 : 0.08),
                            blurRadius: context.responsiveSize(20),
                            spreadRadius: context.responsiveSize(2),
                          ),
                        ],
                      ),
                      child: DiyaWidget(size: context.responsiveSize(58)),
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(24)),

                  StaggeredEntrance(
                    index: 1,
                    child: Text(
                      AppStrings.get('select_language_title', currentLangCode),
                      style: AppTypography.getStyle(
                        languageCode: currentLangCode,
                        fontSize: context.responsiveFontSize(26),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(8)),
                  StaggeredEntrance(
                    index: 2,
                    child: Text(
                      AppStrings.get('select_language_subtitle', currentLangCode),
                      textAlign: TextAlign.center,
                      style: AppTypography.getStyle(
                        languageCode: currentLangCode,
                        fontSize: context.responsiveFontSize(14),
                        color: mutedTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(20)),

                  StaggeredEntrance(
                    index: 3,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.get('choose_language_prompt', currentLangCode),
                        style: AppTypography.getStyle(
                          languageCode: currentLangCode,
                          fontSize: context.responsiveFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepSaffron,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(16)),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _supportedLanguagesInfo.length,
                    itemBuilder: (context, index) {
                      final info = _supportedLanguagesInfo[index];
                      final isSelected = info.language == _selectedLanguage;

                      return Padding(
                        padding: EdgeInsets.only(bottom: context.responsiveSize(14.0)),
                        child: StaggeredEntrance(
                          index: 4 + index,
                          child: TapScaleEffect(
                            onTap: () {
                              setState(() {
                                _selectedLanguage = info.language;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.deepSaffron.withValues(alpha: isDark ? 0.22 : 0.10)
                                    : cardBg,
                                borderRadius: BorderRadius.circular(context.responsiveSize(20.0)),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.deepSaffron
                                      : borderColor,
                                  width: isSelected
                                      ? context.responsiveSize(2.0)
                                      : context.responsiveSize(1.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AppColors.deepSaffron.withValues(alpha: isDark ? 0.25 : 0.10)
                                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                    blurRadius: isSelected
                                        ? context.responsiveSize(12)
                                        : context.responsiveSize(6),
                                    offset: Offset(0, context.responsiveSize(3)),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(context.responsiveSize(18.0)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            info.nativeName,
                                            style: AppTypography.getStyle(
                                              languageCode: info.language.code,
                                              fontSize: context.responsiveFontSize(18),
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                          if (info.nativeName != info.englishName) ...[
                                            SizedBox(height: context.responsiveSize(2)),
                                            Text(
                                              info.englishName,
                                              style: AppTypography.getStyle(
                                                languageCode: info.language.code,
                                                fontSize: context.responsiveFontSize(13),
                                                color: mutedTextColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: context.responsiveSize(26),
                                      height: context.responsiveSize(26),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.deepSaffron
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.deepSaffron
                                              : mutedTextColor.withValues(alpha: 0.5),
                                          width: context.responsiveSize(2),
                                        ),
                                      ),
                                      child: AnimatedScale(
                                        scale: isSelected ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOutBack,
                                        child: isSelected
                                            ? Icon(
                                                Icons.check_rounded,
                                                size: context.responsiveSize(16),
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: context.responsiveSize(28)),

                  StaggeredEntrance(
                    index: 7,
                    child: TapScaleEffect(
                      onTap: _onConfirmLanguage,
                      child: SizedBox(
                        width: double.infinity,
                        height: context.responsiveSize(54),
                        child: ElevatedButton(
                          onPressed: _onConfirmLanguage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepSaffron,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: AppColors.deepSaffron.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.responsiveSize(18.0)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.get('continue_btn', currentLangCode),
                                style: AppTypography.getStyle(
                                  languageCode: currentLangCode,
                                  fontSize: context.responsiveFontSize(17),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: context.responsiveSize(8)),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: context.responsiveSize(20),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
