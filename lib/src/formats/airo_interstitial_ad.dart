import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../aika_ad_ids.dart';
import '../aika_ad_manager.dart';
import '../aika_ad_policy.dart';

/// Pre-fetching Interstitial Ad Manager with frequency capping and policy enforcement.
class AiroInterstitialAdManager {
  AiroInterstitialAdManager({
    this.customAdUnitId,
  });

  final String? customAdUnitId;

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isReady = false;

  bool get isReady => _isReady && _interstitialAd != null;

  /// Pre-loads an interstitial ad into memory.
  Future<void> loadAd({
    bool isLeanback = false,
    bool isCasting = false,
  }) async {
    if (kIsWeb || _isLoading || _isReady) return;

    await AikaAdManager.instance.initialize();

    final allowed = AikaAdManager.instance.policy.decideFormat(
      format: AiroAdFormat.interstitial,
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    ).allowed;

    if (!allowed) return;

    _isLoading = true;
    final adUnitId = customAdUnitId ??
        (const AiroAdUnitConfig()).resolvedInterstitialId;

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          _isReady = true;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _isReady = false;
          _interstitialAd = null;
          debugPrint('Airo Interstitial Ad failed to load: $error');
        },
      ),
    );
  }

  /// Displays the pre-loaded interstitial ad if allowed by policy.
  Future<bool> showIfAllowed({
    bool isLeanback = false,
    bool isCasting = false,
    VoidCallback? onAdDismissed,
    void Function(AdError error)? onAdFailedToShow,
  }) async {
    if (kIsWeb || !_isReady || _interstitialAd == null) {
      onAdDismissed?.call();
      return false;
    }

    final allowed = AikaAdManager.instance.policy.decideFormat(
      format: AiroAdFormat.interstitial,
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    ).allowed;

    if (!allowed) {
      onAdDismissed?.call();
      return false;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AikaAdManager.instance.recordAdImpression(
          null,
          AiroAdFormat.interstitial,
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isReady = false;
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isReady = false;
        debugPrint('Airo Interstitial Ad failed to show: $error');
        onAdFailedToShow?.call(error);
        onAdDismissed?.call();
      },
    );

    await _interstitialAd!.show();
    return true;
  }

  /// Disposes active pre-loaded ad.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isReady = false;
    _isLoading = false;
  }
}
