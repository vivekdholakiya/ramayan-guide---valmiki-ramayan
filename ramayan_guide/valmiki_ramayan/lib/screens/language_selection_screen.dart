import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../models/app_settings.dart';
import '../providers/language_provider.dart';
import '../widgets/diya_painter.dart';
import '../widgets/responsive_container.dart';
import 'home_screen.dart';

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.parchmentLight,
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
            maxWidth: 520.0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deepSaffron.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.warmGold,
                        width: 1.5,
                      ),
                    ),
                    child: const DiyaWidget(size: 54),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('select_language_title', currentLangCode),
                    style: AppTypography.getStyle(
                      languageCode: currentLangCode,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.get('select_language_subtitle', currentLangCode),
                    textAlign: TextAlign.center,
                    style: AppTypography.getStyle(
                      languageCode: currentLangCode,
                      fontSize: 14,
                      color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.get('choose_language_prompt', currentLangCode),
                    style: AppTypography.getStyle(
                      languageCode: currentLangCode,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepSaffron,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Language Options Cards
                  ...AppLanguage.values.map((lang) {
                    final isSelected = lang == _selectedLanguage;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLanguage = lang;
                          });
                        },
                        borderRadius: BorderRadius.circular(16.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.deepSaffron.withValues(alpha: isDark ? 0.25 : 0.12)
                                : (isDark ? AppColors.darkCard : AppColors.parchmentCard),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.deepSaffron
                                  : (isDark ? AppColors.darkBorder : AppColors.parchmentBorder),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.deepSaffron
                                        : AppColors.textMutedBrown,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.deepSaffron,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                lang.label,
                                style: AppTypography.getStyle(
                                  languageCode: lang.code,
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textLightIvory
                                      : AppColors.textDarkBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onConfirmLanguage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepSaffron,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: Text(
                        AppStrings.get('continue_btn', currentLangCode),
                        style: AppTypography.getStyle(
                          languageCode: currentLangCode,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
