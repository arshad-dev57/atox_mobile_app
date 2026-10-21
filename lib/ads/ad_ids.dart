/// Central place for all AdMob unit IDs.
/// Uses Google's official test IDs when [useTestIds] is true, otherwise production IDs.
class AdIds {
  AdIds._();

  // IMPORTANT: set to false before publishing to Play Store
  static const bool useTestIds = true; // set to false before Play Store release

  // ── Production (release) ──────────────────────────────────────────────
  static const String _prodAppId = 'ca-app-pub-1706451826951876~2203691117';
  static const String _prodBanner = 'ca-app-pub-1706451826951876/7344512160';
  static const String _prodInterstitial = 'ca-app-pub-1706451826951876/3325376104';
  // Created as Rewarded Interstitial in AdMob console.
  static const String _prodRewarded = 'ca-app-pub-1706451826951876/1018601959';
  static const String _prodAppOpen = 'ca-app-pub-1706451826951876/6079356949';
  static const String _prodNative = 'ca-app-pub-1706451826951876/5831944931';

  // ── Google official test IDs ──────────────────────────────────────────
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedInterstitial =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _testAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testNative = 'ca-app-pub-3940256099942544/2247696110';

  static String get appId => useTestIds ? _testAppId : _prodAppId;
  static String get banner => useTestIds ? _testBanner : _prodBanner;
  static String get interstitial =>
      useTestIds ? _testInterstitial : _prodInterstitial;
  static String get rewarded =>
      useTestIds ? _testRewardedInterstitial : _prodRewarded;
  static String get appOpen => useTestIds ? _testAppOpen : _prodAppOpen;
  static String get native => useTestIds ? _testNative : _prodNative;
}
