import 'package:flutter/material.dart';

/// AppColors defines the spiritual visual palette for Valmiki Ramayan.
/// Inspired by ancient parchment manuscripts, temple architecture,
/// sacred saffron, and warm divine gold.
class AppColors {
  AppColors._();

  // Primary Spiritual Colors
  static const Color deepSaffron = Color(0xFFD35400); // Sacred orange/saffron
  static const Color brightSaffron = Color(0xFFE67E22);
  static const Color warmGold = Color(0xFFD4AF37); // Ancient gold
  static const Color accentGold = Color(0xFFF39C12);
  static const Color mutedMaroon = Color(0xFF800020); // Sacred Kumkum maroon
  static const Color sacredRed = Color(0xFF900C3F);

  // Light Theme Surfaces (Parchment & Ivory)
  static const Color parchmentLight = Color(0xFFFFFBF0); // Warm ivory background
  static const Color parchmentCard = Color(0xFFFFF8E8); // Warm parchment card surface
  static const Color parchmentBorder = Color(0xFFEFE0C3); // Subtle parchment border
  static const Color parchmentBorderHover = Color(0xFFD4AF37); // Hover gold border
  static const Color textDarkBrown = Color(0xFF3B2F2F); // Primary readable dark text
  static const Color textMutedBrown = Color(0xFF6E5D4F); // Secondary text

  // Dark Theme Surfaces (Spiritual Charcoal & Deep Wood)
  static const Color darkBackground = Color(0xFF18100A); // Deep spiritual charcoal
  static const Color darkCard = Color(0xFF23170F); // Dark parchment card
  static const Color darkBorder = Color(0xFF3D2A1C); // Subtle dark wood border
  static const Color darkBorderHover = Color(0xFFF59E0B); // Dark gold glow border
  static const Color textLightIvory = Color(0xFFF7F1E5); // Off-white readable text
  static const Color textMutedIvory = Color(0xFFC7BCA5); // Secondary dark text

  // Accents & Functional
  static const Color favoriteRed = Color(0xFFE74C3C);
  static const Color errorRed = Color(0xFFC0392B);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color shimmerBaseLight = Color(0xFFEFE0C3);
  static const Color shimmerHighlightLight = Color(0xFFFFFBF0);
  static const Color shimmerBaseDark = Color(0xFF23170F);
  static const Color shimmerHighlightDark = Color(0xFF322216);

  // Gradients
  static const LinearGradient saffronGoldGradient = LinearGradient(
    colors: [deepSaffron, accentGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient parchmentGradientLight = LinearGradient(
    colors: [Color(0xFFFFFBF0), Color(0xFFFFF3E0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient parchmentGradientDark = LinearGradient(
    colors: [Color(0xFF18100A), Color(0xFF23170F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
