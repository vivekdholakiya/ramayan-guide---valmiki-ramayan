import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';
import '../widgets/responsive_container.dart';
import '../widgets/spiritual_decorations.dart';

class TermsOfUseScreen extends ConsumerWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = language.code;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.parchmentLight;
    final cardBg = isDark ? AppColors.darkCard : AppColors.parchmentCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.parchmentBorder;
    final textColor = isDark ? AppColors.textLightIvory : AppColors.textDarkBrown;
    final mutedTextColor = isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: context.responsiveSize(context.isIPad ? 28 : 24),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          AppStrings.get('settings_terms', langCode),
          style: AppTypography.getStyle(
            languageCode: langCode,
            fontSize: context.responsiveFontSize(context.isIPad ? 28 : 20),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 850.0,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsiveSize(20.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(14.0),
                    vertical: context.responsiveSize(6.0),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepSaffron.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.responsiveSize(20.0)),
                    border: Border.all(
                      color: AppColors.warmGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Last Updated: January 2026',
                    style: AppTypography.getStyle(
                      languageCode: langCode,
                      fontSize: context.responsiveFontSize(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepSaffron,
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSize(20)),

                _buildTermsCard(
                  context: context,
                  icon: Icons.verified_user_rounded,
                  title: 'Acceptance of Terms',
                  content:
                      '• By using "Valmiki Ramayan" app you agree to these terms.\n'
                      '• If you do not agree, please discontinue using the app.',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                  isDark: isDark,
                ),
                SizedBox(height: context.responsiveSize(16)),

                _buildTermsCard(
                  context: context,
                  icon: Icons.auto_stories_rounded,
                  title: 'Purpose & Content Usage',
                  content:
                      '• Free for personal, non-commercial devotional use only\n'
                      '• Stories and shlokas are for inspiration and reflection\n'
                      '• Content is based on traditional public sources of Valmiki Ramayana\n'
                      '• May contain simplifications for readability',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                  isDark: isDark,
                ),
                SizedBox(height: context.responsiveSize(16)),

                _buildTermsCard(
                  context: context,
                  icon: Icons.favorite_rounded,
                  title: 'Respect & Devotion',
                  content:
                      '• This app is created with deep reverence for Lord Shri Ram and all spiritual traditions.\n\n'
                      '• It has no intention to offend, misrepresent or harm any religion, belief or community.',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                  isDark: isDark,
                  isImportant: true,
                ),
                SizedBox(height: context.responsiveSize(16)),

                _buildTermsCard(
                  context: context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Disclaimer & Liability',
                  content:
                      '• App is provided "as is" without warranties\n'
                      '• We are not responsible for any direct or indirect damages\n'
                      '• Use at your own discretion\n'
                      '• For authentic scripture studies, refer to original Valmiki Ramayana Sanskrit texts and learned gurus',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                  isDark: isDark,
                ),
                SizedBox(height: context.responsiveSize(16)),

                _buildTermsCard(
                  context: context,
                  icon: Icons.update_rounded,
                  title: 'Changes to Terms',
                  content:
                      '• We may update these terms from time to time.\n\n'
                      '• Continued use of the app means acceptance of updated terms.',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                  isDark: isDark,
                ),

                const MandalaDivider(),

                Center(
                  child: Text(
                    'Hare Rama 🙏\nThank you for your trust',
                    textAlign: TextAlign.center,
                    style: AppTypography.getStyle(
                      languageCode: langCode,
                      fontSize: context.responsiveFontSize(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepSaffron,
                      height: 1.5,
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

  Widget _buildTermsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color mutedTextColor,
    required String langCode,
    required bool isDark,
    bool isImportant = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsiveSize(20.0)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(context.responsiveSize(20.0)),
        border: Border.all(
          color: isImportant ? AppColors.warmGold : borderColor,
          width: isImportant
              ? context.responsiveSize(1.5)
              : context.responsiveSize(1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: context.responsiveSize(10),
            offset: Offset(0, context.responsiveSize(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSize(10.0)),
                decoration: BoxDecoration(
                  color: AppColors.deepSaffron.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(context.responsiveSize(14.0)),
                ),
                child: Icon(
                  icon,
                  color: AppColors.deepSaffron,
                  size: context.responsiveSize(24),
                ),
              ),
              SizedBox(width: context.responsiveSize(14)),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.getStyle(
                    languageCode: langCode,
                    fontSize: context.responsiveFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSize(14)),
          Text(
            content,
            style: AppTypography.getStyle(
              languageCode: langCode,
              fontSize: context.responsiveFontSize(14.5),
              color: mutedTextColor,
              height: 1.6,
              fontWeight: isImportant ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
