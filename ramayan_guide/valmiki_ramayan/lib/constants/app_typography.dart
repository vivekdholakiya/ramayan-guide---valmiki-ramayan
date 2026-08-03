import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTypography configures Google Fonts for Gujarati, Devanagari (Hindi),
/// and standard Noto Sans (English) ensuring clean Unicode rendering.
class AppTypography {
  AppTypography._();

  static TextStyle getStyle({
    required String languageCode,
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 1.5,
    TextDecoration? decoration,
  }) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );

    switch (languageCode) {
      case 'gu':
        return GoogleFonts.notoSansGujarati(textStyle: baseStyle);
      case 'hi':
        return GoogleFonts.notoSansDevanagari(textStyle: baseStyle);
      case 'en':
      default:
        return GoogleFonts.notoSans(textStyle: baseStyle);
    }
  }

  static TextTheme buildTextTheme(String languageCode, TextTheme base) {
    return base.copyWith(
      displayLarge: getStyle(
        languageCode: languageCode,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: getStyle(
        languageCode: languageCode,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: getStyle(
        languageCode: languageCode,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: getStyle(
        languageCode: languageCode,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: getStyle(
        languageCode: languageCode,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.6,
      ),
      bodyMedium: getStyle(
        languageCode: languageCode,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      labelLarge: getStyle(
        languageCode: languageCode,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
