import 'package:flutter/foundation.dart';

String formatDescription(String text) {
  return text
      .replaceAll(r'/n/n', '\n\n')
      .replaceAll(r'/n', '\n')
      .replaceAll(r'\n\n', '\n\n')
      .trim();
}

const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.vivek.valmiki.ramayan';

const String appStoreUrl =
    'https://apps.apple.com/app/id6813295343';


// ── Android Ad Unit IDs ──────────────────────────────────────────────────

const String interstitialId = 'ca-app-pub-8791243074795894/7940378110';
const String rewardedAdId = 'ca-app-pub-8791243074795894/6627296447';
const String bannerAdId = 'ca-app-pub-8791243074795894/5576540829';
const String openAdId = 'ca-app-pub-8791243074795894/4123208297';
const String nativeAdId = 'ca-app-pub-8791243074795894/8301407241';

// ── IOS Ad Unit IDs ──────────────────────────────────────────────────

const String interstitialIdIOS = 'ca-app-pub-8791243074795894/1143498148';
const String rewardedAdIdIOS = 'ca-app-pub-8791243074795894/5239972473';
const String bannerAdIdIOS = 'ca-app-pub-8791243074795894/1196785686';
const String openAdIdIOS = 'ca-app-pub-8791243074795894/7570622346';
const String nativeAdIdIOS = 'ca-app-pub-8791243074795894/3284621923';




String get appUrl {

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return appStoreUrl;
  }

  return playStoreUrl;

}