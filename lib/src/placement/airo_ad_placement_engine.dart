import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../aika_ad_ids.dart';
import '../aika_ad_manager.dart';
import '../aika_ad_policy.dart';

/// Context-aware placement slots for ad targeting.
enum AiroAdPlacementType {
  bannerFooter,
  bannerInline,
  screenTransition,
  rewardedAction,
  appLaunch,
  nativeCard,
  pauseOverlay,
  lowerThird,
}

/// Resolved ad placement decision detailing format, unit ID, and allowance status.
class AiroAdPlacementDecision {
  const AiroAdPlacementDecision({
    required this.allowed,
    required this.format,
    required this.reason,
    required this.formFactor,
    required this.adUnitId,
  });

  final bool allowed;
  final AiroAdFormat format;
  final String reason;
  final AiroDeviceFormFactor formFactor;
  final String adUnitId;
}

/// Intelligent placement router for platform-aware ad placement decisions.
class AiroAdPlacementEngine {
  const AiroAdPlacementEngine({
    AiroAdUnitConfig unitConfig = const AiroAdUnitConfig(),
  }) : _unitConfig = unitConfig;

  final AiroAdUnitConfig _unitConfig;

  /// Evaluates platform, form-factor, session policy, and placement type to decide
  /// whether to load an ad, which format to use, and which Ad Unit ID to target.
  AiroAdPlacementDecision evaluatePlacement({
    required AiroAdPlacementType placementType,
    required BuildContext context,
    bool isLeanback = false,
    bool isCasting = false,
    AiroAdUnitConfig? customUnitConfig,
  }) {
    final formFactor = _detectFormFactor(context);
    final format = _mapPlacementToFormat(placementType);
    final config = customUnitConfig ?? _unitConfig;

    final policyDecision = AikaAdManager.instance.policy.decideFormat(
      format: format,
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    );

    final adUnitId = _resolveUnitId(format, config);

    return AiroAdPlacementDecision(
      allowed: policyDecision.allowed,
      format: format,
      reason: policyDecision.reason,
      formFactor: formFactor,
      adUnitId: adUnitId,
    );
  }

  AiroDeviceFormFactor _detectFormFactor(BuildContext context) {
    if (kIsWeb) return AiroDeviceFormFactor.unknown;
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) {
      return AiroDeviceFormFactor.desktop;
    } else if (width >= 600) {
      return AiroDeviceFormFactor.tablet;
    }
    return AiroDeviceFormFactor.mobile;
  }

  AiroAdFormat _mapPlacementToFormat(AiroAdPlacementType placementType) {
    switch (placementType) {
      case AiroAdPlacementType.bannerFooter:
      case AiroAdPlacementType.bannerInline:
        return AiroAdFormat.banner;
      case AiroAdPlacementType.screenTransition:
        return AiroAdFormat.interstitial;
      case AiroAdPlacementType.rewardedAction:
        return AiroAdFormat.rewarded;
      case AiroAdPlacementType.appLaunch:
        return AiroAdFormat.appOpen;
      case AiroAdPlacementType.nativeCard:
        return AiroAdFormat.native;
      case AiroAdPlacementType.pauseOverlay:
        return AiroAdFormat.pauseOverlay;
      case AiroAdPlacementType.lowerThird:
        return AiroAdFormat.lowerThird;
    }
  }

  String _resolveUnitId(AiroAdFormat format, AiroAdUnitConfig config) {
    switch (format) {
      case AiroAdFormat.banner:
        return config.resolvedBannerId;
      case AiroAdFormat.interstitial:
        return config.resolvedInterstitialId;
      case AiroAdFormat.rewarded:
        return config.resolvedRewardedId;
      case AiroAdFormat.rewardedInterstitial:
        return config.resolvedRewardedInterstitialId;
      case AiroAdFormat.native:
      case AiroAdFormat.pauseOverlay:
      case AiroAdFormat.lowerThird:
        return config.resolvedNativeId;
      case AiroAdFormat.appOpen:
        return config.resolvedAppOpenId;
      case AiroAdFormat.vast:
        return '';
    }
  }
}
