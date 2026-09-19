import 'dart:io';

/// AdMob identifiers for Aika Stream & Airo apps across Android and iOS.
///
/// Production unit IDs ship by default. Pass
/// `--dart-define=AIKA_ADS_USE_TEST_UNITS=true` only on local debug builds.
/// Never put Google sample IDs in a Play AAB or App Store build.
// ignore: do_not_use_environment
const bool aikaAdsUseTestUnits = bool.fromEnvironment(
  'AIKA_ADS_USE_TEST_UNITS',
);

const String aikaAdMobAppId = 'ca-app-pub-7741544685082785~7502136325';

/// Standard Google AdMob Test Ad Unit IDs
class AiroTestAdUnitIds {
  static const String androidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBanner = 'ca-app-pub-3940256099942544/2934735716';

  static const String androidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosInterstitial =
      'ca-app-pub-3940256099942544/4486956145';

  static const String androidRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewarded = 'ca-app-pub-3940256099942544/1712485313';

  static const String androidRewardedInterstitial =
      'ca-app-pub-3940256099942544/5354046379';
  static const String iosRewardedInterstitial =
      'ca-app-pub-3940256099942544/6978759866';

  static const String androidNative = 'ca-app-pub-3940256099942544/2247696110';
  static const String iosNative = 'ca-app-pub-3940256099942544/3986624511';

  static const String androidAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String iosAppOpen = 'ca-app-pub-3940256099942544/5600401536';
}

/// Default Native Ad Unit ID for backward compatibility
const String aikaNativeAdUnitId = aikaAdsUseTestUnits
    ? 'ca-app-pub-3940256099942544/2247696110'
    : 'ca-app-pub-7741544685082785/9923898490';

/// Configuration for Ad Unit IDs per format and platform.
class AiroAdUnitConfig {
  const AiroAdUnitConfig({
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
    this.rewardedAdUnitId,
    this.rewardedInterstitialAdUnitId,
    this.nativeAdUnitId,
    this.appOpenAdUnitId,
  });

  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;
  final String? rewardedAdUnitId;
  final String? rewardedInterstitialAdUnitId;
  final String? nativeAdUnitId;
  final String? appOpenAdUnitId;

  /// Resolves the appropriate Banner Ad Unit ID based on platform or test override.
  String get resolvedBannerId {
    if (bannerAdUnitId != null) return bannerAdUnitId!;
    if (aikaAdsUseTestUnits) {
      return Platform.isIOS
          ? AiroTestAdUnitIds.iosBanner
          : AiroTestAdUnitIds.androidBanner;
    }
    return aikaNativeAdUnitId;
  }

  /// Resolves the appropriate Interstitial Ad Unit ID.
  String get resolvedInterstitialId {
    if (interstitialAdUnitId != null) return interstitialAdUnitId!;
    if (aikaAdsUseTestUnits) {
      return Platform.isIOS
          ? AiroTestAdUnitIds.iosInterstitial
          : AiroTestAdUnitIds.androidInterstitial;
    }
    return 'ca-app-pub-7741544685082785/1033173712';
  }

  /// Resolves the appropriate Rewarded Ad Unit ID.
  String get resolvedRewardedId {
    if (rewardedAdUnitId != null) return rewardedAdUnitId!;
    if (aikaAdsUseTestUnits) {
      return Platform.isIOS
          ? AiroTestAdUnitIds.iosRewarded
          : AiroTestAdUnitIds.androidRewarded;
    }
    return 'ca-app-pub-7741544685082785/5224354917';
  }

  /// Resolves the appropriate Rewarded Interstitial Ad Unit ID.
  String get resolvedRewardedInterstitialId {
    if (rewardedInterstitialAdUnitId != null) {
      return rewardedInterstitialAdUnitId!;
    }
    if (aikaAdsUseTestUnits) {
      return Platform.isIOS
          ? AiroTestAdUnitIds.iosRewardedInterstitial
          : AiroTestAdUnitIds.androidRewardedInterstitial;
    }
    return 'ca-app-pub-7741544685082785/5354046379';
  }

  /// Resolves the appropriate Native Ad Unit ID.
  String get resolvedNativeId {
    if (nativeAdUnitId != null) return nativeAdUnitId!;
    if (aikaAdsUseTestUnits) {
      return Platform.isIOS
          ? AiroTestAdUnitIds.iosNative
          : AiroTestAdUnitIds.androidNative;
    }
    return aikaNativeAdUnitId;
  }

  /// Resolves the appropriate App Open Ad Unit ID.
  String get resolvedAppOpenId {
    if (appOpenAdUnitId != null) return appOpenAdUnitId!;
    if (aikaAdsUseTestUnits) {
      return Platform.isIOS
          ? AiroTestAdUnitIds.iosAppOpen
          : AiroTestAdUnitIds.androidAppOpen;
    }
    return 'ca-app-pub-7741544685082785/9257395921';
  }
}

