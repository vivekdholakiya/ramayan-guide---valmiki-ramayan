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

const String bannerAdId = 'ca-app-pub-8791243074795894/4378694241';
const String interstitialId = 'ca-app-pub-8791243074795894/4681946577';
const String rewardedAdId = 'ca-app-pub-8791243074795894/7602878520';
const String nativeAdId = 'ca-app-pub-8791243074795894/7682769571';
const String openAdId = 'ca-app-pub-8791243074795894/4517550184';


// ── IOS Ad Unit IDs ──────────────────────────────────────────────────

const String bannerAdIdIOS = 'ca-app-pub-8791243074795894/8923699053';
const String interstitialIdIOS = 'ca-app-pub-8791243074795894/3368864909';
const String rewardedAdIdIOS = 'ca-app-pub-8791243074795894/4679358402';
const String nativeAdIdIOS = 'ca-app-pub-8791243074795894/6345637175';
const String openAdIdIOS = 'ca-app-pub-8791243074795894/3366276730';


String get appUrl {

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return appStoreUrl;
  }

  return playStoreUrl;

}