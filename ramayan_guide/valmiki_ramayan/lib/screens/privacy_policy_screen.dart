import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/language_provider.dart';
import '../services/context_extensions.dart';
import '../widgets/responsive_container.dart';
import '../widgets/spiritual_decorations.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

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
            size: context.responsiveSize(24),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          AppStrings.get('settings_privacy', langCode),
          style: AppTypography.getStyle(
            languageCode: langCode,
            fontSize: context.responsiveFontSize(20),
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

                _buildPolicyCard(
                  context: context,
                  icon: Icons.security_rounded,
                  title: 'We Protect Your Privacy',
                  content:
                      '• No names, emails, phone numbers, device IDs or location data\n'
                      '• No analytics, tracking or third-party SDKs\n'
                      '• No data is ever sent to servers or shared with anyone\n'
                      '• All your preferences (favorites, settings) are stored only on your device using local storage.',
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                ),
                SizedBox(height: context.responsiveSize(16)),

                _buildPolicyCard(
                  context: context,
                  icon: Icons.block_rounded,
                  title: 'No Data Collection & Sharing',
                  content:
                      'Since we collect nothing, there is nothing to share, sell or misuse.\n'
                      '• No advertising networks\n'
                      '• No crash reporting tools\n'
                      '• No unnecessary permissions',
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                ),
                SizedBox(height: context.responsiveSize(16)),

                _buildPolicyCard(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: 'Content & Disclaimer',
                  content:
                      '• Stories and information are curated with extreme care from authentic Valmiki Ramayana public sources.\n'
                      '• While we strive to be respectful and accurate, content is provided for inspiration and reflection.\n'
                      '• This app is created with deep devotion and has no intention to hurt or misrepresent any belief.',
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  langCode: langCode,
                  isImportant: true,
                ),

                const MandalaDivider(),

                Center(
                  child: Text(
                    'Jai Shri Ram 🙏\nThank you for your trust',
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

  Widget _buildPolicyCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color mutedTextColor,
    required String langCode,
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
