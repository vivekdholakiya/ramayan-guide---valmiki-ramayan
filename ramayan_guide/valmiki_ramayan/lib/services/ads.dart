import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_colors.dart';
import '../constants/util.dart';
import '../widgets/diya_painter.dart';
import 'context_extensions.dart';

final AdsControllerMain adsControllerVar = AdsControllerMain(
  interstitialId: Platform.isIOS ? interstitialIdIOS : interstitialId,
  rewardedId: Platform.isIOS ? rewardedAdIdIOS : rewardedAdId,
  bannerId: Platform.isIOS ? bannerAdIdIOS : bannerAdId,
  appOpenId: Platform.isIOS ? openAdIdIOS : openAdId,
  nativeAdId: Platform.isIOS ? nativeAdIdIOS : nativeAdId,
);

class AdsControllerMain with WidgetsBindingObserver {
  static final ValueNotifier<bool> mobileAdsInitialized = ValueNotifier<bool>(
    false,
  );

  static void markMobileAdsInitialized() {
    if (!mobileAdsInitialized.value) mobileAdsInitialized.value = true;
  }

  final String interstitialId;
  final String rewardedId;
  final String bannerId;
  final String appOpenId;
  final String nativeAdId;

  AdsControllerMain({
    required this.interstitialId,
    required this.rewardedId,
    required this.bannerId,
    required this.appOpenId,
    required this.nativeAdId,
  }) {
    _getUserConsent();
    // Lifecycle observer for App Open ads — attached here so nothing needs
    // to change in main.dart beyond referencing `adsControllerVar` once.
    WidgetsBinding.instance.addObserver(this);
    // Preload the very first App Open ad as early as possible.
    loadAppOpenAd();
  }

  Future<bool> _ensureMobileAdsReady() async {
    if (mobileAdsInitialized.value) return true;

    final completer = Completer<bool>();

    void listener() {
      if (mobileAdsInitialized.value && !completer.isCompleted) {
        completer.complete(true);
        mobileAdsInitialized.removeListener(listener);
      }
    }

    mobileAdsInitialized.addListener(listener);

    try {
      return await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          mobileAdsInitialized.removeListener(listener);
          return false;
        },
      );
    } catch (_) {
      mobileAdsInitialized.removeListener(listener);
      return false;
    }
  }

  // ── Cross-format full-screen-ad lock ───────────────────────────
  // `adShowed == true` means "no full-screen ad is currently on screen" —
  // every full-screen format (App Open, Interstitial, Rewarded) reads this
  // before showing and sets it while it's up, so they never overlap.
  bool adShowed = true;
  DateTime? _lastFullScreenAdShownAt;
  static const Duration _crossFormatGap = Duration(seconds: 60);

  bool get _canShowAnyFullScreenAd {
    if (!adShowed) return false; // something is already showing
    if (_lastFullScreenAdShownAt == null) return true;
    return DateTime.now().difference(_lastFullScreenAdShownAt!) >=
        _crossFormatGap;
  }

  // ── App Open Ad ────────────────────────────────────────────────
  AppOpenAd? appOpenAd;
  bool _isLoadingAppOpenAd = false;
  DateTime? _appOpenLoadedAt;
  bool _isAppOpenAdShowing = false;
  bool _hasHadFirstResume = false;
  int _appOpenLoadAttempts = 0;

  /// Google recommends not showing a cached App Open ad once it's older
  /// than ~4 hours.
  static const Duration _appOpenMaxAge = Duration(hours: 4);

  bool get _isAppOpenAdExpired {
    if (_appOpenLoadedAt == null) return true;
    return DateTime.now().difference(_appOpenLoadedAt!) > _appOpenMaxAge;
  }

  bool get _isAppOpenAdAvailable => appOpenAd != null && !_isAppOpenAdExpired;

  Future<void> loadAppOpenAd() async {
    if (!await _ensureMobileAdsReady()) return;
    if (_isLoadingAppOpenAd || _isAppOpenAdAvailable) return;
    _isLoadingAppOpenAd = true;

    try {
      await AppOpenAd.load(
        adUnitId: appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoadingAppOpenAd = false;
            _appOpenLoadAttempts = 0;
            appOpenAd = ad;
            _appOpenLoadedAt = DateTime.now();
          },
          onAdFailedToLoad: (error) {
            _isLoadingAppOpenAd = false;
            appOpenAd = null;
            _appOpenLoadAttempts++;
            // Gentle backoff instead of hammering the network on repeated
            // no-fill/no-internet failures.
            final delaySeconds = [
              30,
              60,
              120,
              300,
            ][(_appOpenLoadAttempts - 1).clamp(0, 3)];
            Future.delayed(Duration(seconds: delaySeconds), () {
              if (!_isAppOpenAdAvailable) loadAppOpenAd();
            });
          },
        ),
      );
    } catch (_) {
      _isLoadingAppOpenAd = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    // The very first "resumed" event fires right after cold start — that
    // moment belongs to the splash screen, not an App Open ad. Only show
    // on genuine background -> foreground transitions.
    if (!_hasHadFirstResume) {
      _hasHadFirstResume = true;
      return;
    }
    showOpenAdIfEligible();
  }

  /// Shows the cached App Open ad only if every rule allows it. Safe to
  /// call speculatively — it silently no-ops when conditions aren't met.
  void showOpenAdIfEligible() {
    if (_isAppOpenAdShowing) return; // never show two at once

    if (!_isAppOpenAdAvailable) {
      loadAppOpenAd();
      return;
    }

    if (!_canShowAnyFullScreenAd) {
      return; // an Interstitial/Rewarded ad is showing or just closed
    }

    _isAppOpenAdShowing = true;
    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        adShowed = false;
        _lastFullScreenAdShownAt = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isAppOpenAdShowing = false;
        adShowed = true;
        ad.dispose();
        appOpenAd = null;
        loadAppOpenAd(); // always preload the next one right away
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAppOpenAdShowing = false;
        adShowed = true;
        ad.dispose();
        appOpenAd = null;
        loadAppOpenAd();
      },
    );
    appOpenAd!.show();
  }

  // ── Interstitial ─────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  bool _isInterstitialLoading = false;

  Future<void> loadInterstitialAd() async {
    if (!await _ensureMobileAdsReady()) return;
    if (_isInterstitialReady || _isInterstitialLoading) return;
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          _isInterstitialReady = false;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void showInterstititalAd(BuildContext context, {VoidCallback? onRoute}) {
    // Cross-format guard: never overlap App Open/Rewarded, never show
    // within 60s of another full-screen ad (e.g. right after App Open).
    if (!_canShowAnyFullScreenAd) {
      onRoute?.call();
      return;
    }

    if (_interstitialAd == null) {
      adShowed = true;
      loadInterstitialAd();
      onRoute?.call();
      return;
    }

    _interstitialAd!
      ..fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          adShowed = false;
          _lastFullScreenAdShownAt = DateTime.now();
        },
        onAdDismissedFullScreenContent: (ad) async {
          adShowed = true;
          _isInterstitialReady = false;
          _interstitialAd?.dispose();
          _interstitialAd = null;
          // Reload ONLY after it was shown/dismissed.
          loadInterstitialAd();
          onRoute?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          adShowed = true;
          _isInterstitialReady = false;
          _interstitialAd?.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onRoute?.call();
        },
      )
      ..show();
  }

  int _completedStoryViews = 0;
  int get completedStoryViews => _completedStoryViews;

  /// Tracks story/chapter views and triggers an Interstitial ad on every 3rd completed view.
  void onStoryExit(BuildContext context, {required VoidCallback onContinue}) {
    _completedStoryViews++;
    if (_completedStoryViews % 3 == 0) {
      showInterstititalAd(context, onRoute: onContinue);
    } else {
      onContinue();
    }
  }

  // ── Rewarded ─────────────────────────────────────────────────
  RewardedAd? _rewardedAd;
  bool _isRewardedReady = false;
  bool _isRewardedLoading = false;

  Future<void> loadRewardedAd() async {
    if (!await _ensureMobileAdsReady()) return;
    if (_isRewardedReady || _isRewardedLoading) return;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
          _isRewardedReady = false;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Shows the existing confirmation dialog, then plays rewarded ad.
  /// If user watches and earns reward, calls [onRewardGranted].
  /// If ad is not ready or fails, does NOT grant reward, notifies user, and reloads.
  void showRewardedAd(
    BuildContext context, {
    String? title,
    String? description,
    String? watchButtonText,
    String? maybeLaterText,
    required VoidCallback onRewardGranted,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: ctx.responsiveSize(ctx.isIPad ? 60 : 24),
            vertical: ctx.responsiveSize(24),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ctx.responsiveSize(ctx.isIPad ? 460 : 380),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
              borderRadius: BorderRadius.circular(ctx.responsiveSize(24)),
              border: Border.all(
                color: AppColors.warmGold.withValues(alpha: isDark ? 0.45 : 0.65),
                width: ctx.responsiveSize(1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.12),
                  blurRadius: ctx.responsiveSize(24),
                  offset: Offset(0, ctx.responsiveSize(8)),
                ),
                BoxShadow(
                  color: AppColors.warmGold.withValues(alpha: isDark ? 0.15 : 0.2),
                  blurRadius: ctx.responsiveSize(12),
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ctx.responsiveSize(22),
                vertical: ctx.responsiveSize(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row with Diya and Close Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.all(ctx.responsiveSize(6)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.06),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: isDark
                                  ? AppColors.textMutedIvory
                                  : AppColors.textMutedBrown,
                              size: ctx.responsiveSize(20),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ctx.responsiveSize(12)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.deepSaffron.withValues(alpha: 0.12),
                              border: Border.all(
                                color: AppColors.warmGold.withValues(alpha: 0.4),
                                width: ctx.responsiveSize(1),
                              ),
                            ),
                            child: DiyaWidget(size: ctx.responsiveSize(36)),
                          ),
                          SizedBox(height: ctx.responsiveSize(14)),
                          Text(
                            title ?? "Unlock Feature",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: ctx.responsiveFontSize(ctx.isIPad ? 24 : 20),
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textLightIvory
                                  : AppColors.textDarkBrown,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: ctx.responsiveSize(14)),
                  // Sacred ornamental divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.warmGold.withValues(alpha: 0.0),
                                AppColors.warmGold.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ctx.responsiveSize(8.0),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: ctx.responsiveSize(14),
                          color: AppColors.warmGold,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.warmGold.withValues(alpha: 0.6),
                                AppColors.warmGold.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ctx.responsiveSize(16)),
                  Text(
                    description ?? "Watch a short ad to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedIvory
                          : AppColors.textMutedBrown,
                      fontSize: ctx.responsiveFontSize(ctx.isIPad ? 17 : 14.5),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: ctx.responsiveSize(22)),
                  // Watch & Unlock button with saffron/gold theme gradient
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showRewardedAdInternal(
                        context,
                        onRewardGranted: onRewardGranted,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: ctx.responsiveSize(14),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ctx.responsiveSize(16),
                        ),
                        gradient: AppColors.saffronGoldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepSaffron.withValues(alpha: 0.35),
                            blurRadius: ctx.responsiveSize(12),
                            offset: Offset(0, ctx.responsiveSize(4)),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: ctx.responsiveSize(22),
                          ),
                          SizedBox(width: ctx.responsiveSize(8)),
                          Text(
                            watchButtonText ?? "Watch Ads",
                            style: TextStyle(
                              fontSize: ctx.responsiveFontSize(ctx.isIPad ? 19 : 16.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ctx.responsiveSize(10)),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      maybeLaterText ?? "Maybe Later",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textMutedIvory.withValues(alpha: 0.8)
                            : AppColors.textMutedBrown.withValues(alpha: 0.8),
                        fontSize: ctx.responsiveFontSize(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRewardedAdInternal(
    BuildContext context, {
    required VoidCallback onRewardGranted,
  }) {
    if (!_isRewardedReady || _rewardedAd == null) {
      adShowed = true;
      loadRewardedAd();
      showAdNotReady(context);
      return;
    }

    if (!_canShowAnyFullScreenAd) {
      showAdNotReady(context);
      return;
    }

    _rewardedAd!
      ..fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          adShowed = false;
          _lastFullScreenAdShownAt = DateTime.now();
        },
        onAdDismissedFullScreenContent: (_) {
          adShowed = true;
          _isRewardedReady = false;
          _rewardedAd?.dispose();
          _rewardedAd = null;
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (_, error) {
          adShowed = true;
          _isRewardedReady = false;
          _rewardedAd?.dispose();
          _rewardedAd = null;
          loadRewardedAd();
          showAdNotReady(context);
        },
      )
      ..show(
        onUserEarnedReward: (_, reward) {
          onRewardGranted();
        },
      );
  }

  // ── Banner (single instance) ───────────────────────────────────
  BannerAd? _bannerAd;
  bool _isBannerLoading = false;
  final ValueNotifier<bool> bannerLoaded = ValueNotifier<bool>(false);

  BannerAd? get bannerAd => _bannerAd;

  Future<void> loadBannerAdOnce() async {
    if (!await _ensureMobileAdsReady()) return;
    if (bannerLoaded.value || _isBannerLoading || _bannerAd != null) return;
    _isBannerLoading = true;
    _bannerAd = BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          bannerLoaded.value = true;
          _isBannerLoading = false;
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _bannerAd = null;
          bannerLoaded.value = false;
          _isBannerLoading = false;
        },
      ),
    )..load();
  }

  // ── Consent ───────────────────────────────────────────────────
  void _getUserConsent() {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentForm();
        }
      },
      (_) {},
    );
  }

  void _loadConsentForm() {
    ConsentForm.loadConsentForm((form) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        form.show((_) => _loadConsentForm());
      }
    }, (_) {});
  }

  void showAdNotReady(BuildContext context, [String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? "Ad not available right now. Please try again.",
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    appOpenAd?.dispose();
    _bannerAd?.dispose();
  }
}

// ── Banner Widget ─────────────────────────────────────────────────
class AdsBannerWidget extends StatefulWidget {
  final double size;

  const AdsBannerWidget({super.key, this.size = 0.0});

  @override
  State<AdsBannerWidget> createState() => _AdsBannerWidgetState();
}

class _AdsBannerWidgetState extends State<AdsBannerWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: adsControllerVar.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _bannerAd == null) {
      return const SizedBox();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

// ── Native Ad Widget ────────────────────────────────────────────────
enum NativeAdTemplateType { small, medium }

/// A reusable, self-contained Native Ad. Drop it into a `ListView`, an
/// article page, or between content sections — it manages its own
/// load/loading/error state and disposes its `NativeAd` correctly.
class NativeAdWidget extends StatefulWidget {
  final NativeAdTemplateType templateType;
  final double? height;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;

  /// Optional custom loading placeholder. Defaults to a subtle container
  /// with a small spinner.
  final WidgetBuilder? loadingBuilder;

  /// Optional custom "failed to load" placeholder. Defaults to collapsing
  /// to nothing so a failed ad never leaves a visible gap in your layout.
  final WidgetBuilder? errorBuilder;

  const NativeAdWidget({
    super.key,
    this.templateType = NativeAdTemplateType.medium,
    this.height,
    this.margin = const EdgeInsets.symmetric(vertical: 10),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.backgroundColor,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    NativeAd(
      adUnitId: adsControllerVar.nativeAdId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType == NativeAdTemplateType.small
            ? TemplateType.small
            : TemplateType.medium,
        mainBackgroundColor: widget.backgroundColor ?? Colors.transparent,
        cornerRadius: 16,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose(); // widget was removed before the ad came back
            return;
          }
          setState(() {
            _nativeAd = ad as NativeAd;
            _isLoaded = true;
            _failed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _nativeAd = null;
            _isLoaded = false;
            _failed = true;
          });
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  double get _defaultHeight =>
      widget.templateType == NativeAdTemplateType.small ? 100 : 320;

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      // Fail silently: never leave a broken box in the middle of content.
      return widget.errorBuilder?.call(context) ?? const SizedBox.shrink();
    }

    if (!_isLoaded || _nativeAd == null) {
      return widget.loadingBuilder?.call(context) ??
          _defaultLoadingPlaceholder();
    }

    return Container(
      height: widget.height ?? _defaultHeight,
      margin: widget.margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: widget.borderRadius),
      child: AdWidget(ad: _nativeAd!),
    );
  }

  Widget _defaultLoadingPlaceholder() {
    return Container(
      height: widget.height ?? _defaultHeight,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: widget.borderRadius,
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
