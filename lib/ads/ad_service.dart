import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// Central AdMob service (GetxService).
/// Handles Interstitial, Rewarded Interstitial, and App Open ads with
/// load / show / dispose / reload and safe failure handling.
class AdService extends GetxService with WidgetsBindingObserver {
  static AdService get to => Get.find<AdService>();

  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  bool _isAppOpenLoading = false;

  /// True while any full-screen ad is on screen.
  bool isShowingAd = false;

  /// Skip App Open on cold start; only show after returning from background.
  bool _isFirstLaunch = true;

  // Frequency cap: every N screen changes + min gap between shows.
  static const int _screensBeforeInterstitial = 3;
  static const Duration _minInterstitialGap = Duration(seconds: 60);
  int _screenChangeCount = 0;
  DateTime? _lastInterstitialShownAt;

  bool get isSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  Future<AdService> init() async {
    if (!isSupported) {
      debugPrint('[AdService] Ads not supported on this platform.');
      return this;
    }

    try {
      await MobileAds.instance.initialize();
      WidgetsBinding.instance.addObserver(this);
      loadInterstitial();
      loadRewarded();
      loadAppOpen();
    } catch (e, st) {
      debugPrint('[AdService] init failed: $e\n$st');
    }
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    super.onClose();
  }

  // ── Lifecycle (App Open) ──────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  void _onAppResumed() {
    if (_isFirstLaunch) {
      _isFirstLaunch = false;
      return;
    }
    if (isShowingAd) return;
    showAppOpenAd();
  }

  // ── Screen navigation → interstitial frequency cap ────────────────────

  /// Call on each meaningful screen / tab change.
  void onScreenChanged() {
    if (!isSupported) return;
    _screenChangeCount++;
    if (_screenChangeCount < _screensBeforeInterstitial) return;

    final last = _lastInterstitialShownAt;
    if (last != null && DateTime.now().difference(last) < _minInterstitialGap) {
      return;
    }

    showInterstitialAd();
  }

  // ── Interstitial ──────────────────────────────────────────────────────

  void loadInterstitial() {
    if (!isSupported || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _attachInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void _attachInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Interstitial failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
    );
  }

  Future<void> showInterstitialAd() async {
    if (!isSupported || isShowingAd) return;
    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitial();
      return;
    }

    try {
      _screenChangeCount = 0;
      _lastInterstitialShownAt = DateTime.now();
      await ad.show();
    } catch (e) {
      debugPrint('[AdService] Interstitial show error: $e');
      isShowingAd = false;
      _interstitialAd?.dispose();
      _interstitialAd = null;
      loadInterstitial();
    }
  }

  // ── Rewarded Interstitial ─────────────────────────────────────────────

  void loadRewarded() {
    if (!isSupported || _isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedInterstitialAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _attachRewardedCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  void _attachRewardedCallbacks(RewardedInterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Rewarded failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
    );
  }

  /// Shows a rewarded interstitial. Invokes [onReward] only when the user
  /// earns the reward. Returns `true` if the ad was shown.
  Future<bool> showRewardedAd({required VoidCallback onReward}) async {
    if (!isSupported || isShowingAd) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      loadRewarded();
      return false;
    }

    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onReward();
        },
      );
      return true;
    } catch (e) {
      debugPrint('[AdService] Rewarded show error: $e');
      isShowingAd = false;
      _rewardedAd?.dispose();
      _rewardedAd = null;
      loadRewarded();
      return false;
    }
  }

  // ── App Open ──────────────────────────────────────────────────────────

  void loadAppOpen() {
    if (!isSupported || _isAppOpenLoading || _appOpenAd != null) return;
    _isAppOpenLoading = true;

    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenLoading = false;
          _attachAppOpenCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] App Open failed to load: $error');
          _appOpenAd = null;
          _isAppOpenLoading = false;
        },
      ),
    );
  }

  void _attachAppOpenCallbacks(AppOpenAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] App Open failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpen();
      },
    );
  }

  Future<void> showAppOpenAd() async {
    if (!isSupported || isShowingAd) return;
    final ad = _appOpenAd;
    if (ad == null) {
      loadAppOpen();
      return;
    }

    try {
      await ad.show();
    } catch (e) {
      debugPrint('[AdService] App Open show error: $e');
      isShowingAd = false;
      _appOpenAd?.dispose();
      _appOpenAd = null;
      loadAppOpen();
    }
  }
}
