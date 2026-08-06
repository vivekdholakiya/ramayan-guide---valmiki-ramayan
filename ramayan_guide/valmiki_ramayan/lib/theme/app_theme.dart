import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../widgets/animated_interactions.dart';

/// AppTheme builds Material 3 light & dark themes tailored for the
/// spiritual aesthetic of Valmiki Ramayan.
class AppTheme {
  AppTheme._();

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SpiritualPageTransitionsBuilder(),
      TargetPlatform.iOS: SpiritualPageTransitionsBuilder(),
      TargetPlatform.macOS: SpiritualPageTransitionsBuilder(),
      TargetPlatform.windows: SpiritualPageTransitionsBuilder(),
      TargetPlatform.linux: SpiritualPageTransitionsBuilder(),
    },
  );

  static ThemeData lightTheme(String languageCode) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );
    final textTheme = AppTypography.buildTextTheme(languageCode, base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.parchmentLight,
      pageTransitionsTheme: _pageTransitionsTheme,
      colorScheme: ColorScheme.light(
        primary: AppColors.deepSaffron,
        secondary: AppColors.warmGold,
        surface: AppColors.parchmentCard,
        onPrimary: Colors.white,
        onSecondary: AppColors.textDarkBrown,
        onSurface: AppColors.textDarkBrown,
        error: AppColors.errorRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.parchmentLight,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDarkBrown),
        titleTextStyle: AppTypography.getStyle(
          languageCode: languageCode,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkBrown,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.parchmentCard,
        elevation: 1,
        shadowColor: AppColors.warmGold.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.parchmentBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.parchmentCard,
        indicatorColor: AppColors.deepSaffron.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.deepSaffron);
          }
          return const IconThemeData(color: AppColors.textMutedBrown);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return AppTypography.getStyle(
            languageCode: languageCode,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.deepSaffron : AppColors.textMutedBrown,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.parchmentBorder,
        thickness: 1,
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData darkTheme(String languageCode) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    final textTheme = AppTypography.buildTextTheme(languageCode, base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      pageTransitionsTheme: _pageTransitionsTheme,
      colorScheme: ColorScheme.dark(
        primary: AppColors.brightSaffron,
        secondary: AppColors.warmGold,
        surface: AppColors.darkCard,
        onPrimary: Colors.black,
        onSecondary: AppColors.textLightIvory,
        onSurface: AppColors.textLightIvory,
        error: AppColors.errorRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textLightIvory),
        titleTextStyle: AppTypography.getStyle(
          languageCode: languageCode,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textLightIvory,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        indicatorColor: AppColors.brightSaffron.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brightSaffron);
          }
          return const IconThemeData(color: AppColors.textMutedIvory);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return AppTypography.getStyle(
            languageCode: languageCode,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.brightSaffron : AppColors.textMutedIvory,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      textTheme: textTheme,
    );
  }
}
