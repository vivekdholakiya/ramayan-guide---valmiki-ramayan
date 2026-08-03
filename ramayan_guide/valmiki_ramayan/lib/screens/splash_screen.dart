import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_typography.dart';
import '../providers/language_provider.dart';
import '../widgets/diya_painter.dart';
import 'language_selection_screen.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final hasSelectedLang =
        ref.read(languageProvider.notifier).hasSelectedLanguage;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasSelectedLang
                ? const MainNavigationScreen()
                : const LanguageSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.parchmentLight,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepSaffron.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.warmGold,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warmGold.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const DiyaWidget(size: 72),
                ),
                const SizedBox(height: 28),
                Text(
                  AppStrings.get('app_title', language.code),
                  style: AppTypography.getStyle(
                    languageCode: language.code,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLightIvory : AppColors.textDarkBrown,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    AppStrings.get('app_subtitle', language.code),
                    textAlign: TextAlign.center,
                    style: AppTypography.getStyle(
                      languageCode: language.code,
                      fontSize: 14,
                      color: isDark ? AppColors.textMutedIvory : AppColors.textMutedBrown,
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
}
