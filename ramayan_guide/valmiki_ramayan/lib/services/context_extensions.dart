import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension UsefulExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// True if the current platform is Apple iOS (iPhone or iPad)
  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// True if running on an Apple iPad device on iOS (shortestSide >= 600 pt)
  bool get isIPad => isIOS && MediaQuery.of(this).size.shortestSide >= 600;

  /// True if running on any tablet form factor (shortestSide >= 600 pt)
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;

  /// Orientation helpers
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Returns [ipad] value if running on iPad on iOS, otherwise returns [phone]
  T responsiveValue<T>({required T phone, required T ipad}) => isIPad ? ipad : phone;

  double get topPadding =>
      MediaQuery.paddingOf(this).top > 0 ? MediaQuery.paddingOf(this).top : 15;
  double get topPaddingRaw => MediaQuery.paddingOf(this).top;
  double get bottomPaddingRaw => MediaQuery.paddingOf(this).bottom;
  double get bottomPadding =>
      MediaQuery.paddingOf(this).bottom > 0 ? MediaQuery.paddingOf(this).bottom : 18;
}

extension ResponsiveSizeExtensions on BuildContext {
  double responsiveSize(double size, {double? min, double? max}) {
    final scale = MediaQuery.of(this).size.width / 430.0;
    final val = size * scale;
    return val.clamp(min ?? size - 15, max ?? size + 8);
  }

  double responsiveFontSize(double size, {double? min, double? max}) {
    final scale = MediaQuery.of(this).size.width / 430.0;
    final val = size * scale;
    return val.clamp(min ?? size, max ?? size + 4);
  }
}
