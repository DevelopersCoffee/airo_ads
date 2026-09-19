import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../aika_ad_ids.dart';
import '../aika_ad_manager.dart';
import '../aika_ad_policy.dart';

/// Manager for Rewarded & Rewarded Interstitial ad formats.
class AiroRewardedAdManager {
  AiroRewardedAdManager({
    this.customAdUnitId,
    this.isRewardedInterstitial = false,
  });

  final String? customAdUnitId;
  final bool isRewardedInterstitial;

  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isLoading = false;
  bool _isReady = false;

  bool get isReady =>
      _isReady && (_rewardedAd != null || _rewardedInterstitialAd != null);

  /// Pre-loads a rewarded ad.
  Future<void> loadAd({
    bool isLeanback = false,
    bool isCasting = false,
  }) async {
    if (kIsWeb || _isLoading || _isReady) return;

    await AikaAdManager.instance.initialize();

    final format = isRewardedInterstitial
        ? AiroAdFormat.rewardedInterstitial
        : AiroAdFormat.rewarded;

    final allowed = AikaAdManager.instance.policy.decideFormat(
      format: format,
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    ).allowed;

    if (!allowed) return;

    _isLoading = true;
    final config = const AiroAdUnitConfig();
    final adUnitId = customAdUnitId ??
        (isRewardedInterstitial
            ? config.resolvedRewardedInterstitialId
            : config.resolvedRewardedId);

    if (isRewardedInterstitial) {
      await RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback:
            RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedInterstitialAd = ad;
            _isLoading = false;
            _isReady = true;
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            _isReady = false;
            _rewardedInterstitialAd = null;
            debugPrint('Airo Rewarded Interstitial Ad failed to load: $error');
          },
        ),
      );
    } else {
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
            _isReady = true;
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            _isReady = false;
            _rewardedAd = null;
            debugPrint('Airo Rewarded Ad failed to load: $error');
          },
        ),
      );
    }
  }

  /// Displays the rewarded ad and triggers callbacks on completion / reward earned.
  Future<bool> showIfAllowed({
    required void Function(RewardItem reward) onUserEarnedReward,
    bool isLeanback = false,
    bool isCasting = false,
    VoidCallback? onAdDismissed,
    void Function(AdError error)? onAdFailedToShow,
  }) async {
    if (kIsWeb || !_isReady) {
      onAdDismissed?.call();
      return false;
    }

    final format = isRewardedInterstitial
        ? AiroAdFormat.rewardedInterstitial
        : AiroAdFormat.rewarded;

    final allowed = AikaAdManager.instance.policy.decideFormat(
      format: format,
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    ).allowed;

    if (!allowed) {
      onAdDismissed?.call();
      return false;
    }

    if (isRewardedInterstitial && _rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AikaAdManager.instance.recordAdImpression(null, format);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedInterstitialAd = null;
          _isReady = false;
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedInterstitialAd = null;
          _isReady = false;
          onAdFailedToShow?.call(error);
          onAdDismissed?.call();
        },
      );
      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (_, reward) => onUserEarnedReward(reward),
      );
      return true;
    } else if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AikaAdManager.instance.recordAdImpression(null, format);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _isReady = false;
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          _isReady = false;
          onAdFailedToShow?.call(error);
          onAdDismissed?.call();
        },
      );
      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) => onUserEarnedReward(reward),
      );
      return true;
    }

    onAdDismissed?.call();
    return false;
  }

  /// Disposes loaded ads.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _rewardedAd = null;
    _rewardedInterstitialAd = null;
    _isReady = false;
    _isLoading = false;
  }
}
