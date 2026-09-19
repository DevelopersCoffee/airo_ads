import 'package:flutter/foundation.dart';

import 'aika_ad_ids.dart';
import 'aika_ad_policy.dart';
import 'aika_ad_sdk.dart';
import 'placement/airo_ad_placement_engine.dart';

/// Device form factors supported for ad targeting.
enum AiroDeviceFormFactor { mobile, tablet, tv, desktop, unknown }

/// Session-scoped AdMob gate for Aika Stream & Airo apps.
///
/// Initializes Mobile Ads only on Android/iOS phone & tablet profiles. Leanback,
/// web, and desktop never load the SDK.
class AikaAdManager {
  AikaAdManager._({
    AikaAdPolicy? policy,
    AikaAdSdk? sdk,
    AiroAdUnitConfig unitConfig = const AiroAdUnitConfig(),
  })  : policy = policy ?? AikaAdPolicy(),
        _sdk = sdk ?? const AikaAdSdk(),
        placementEngine = AiroAdPlacementEngine(unitConfig: unitConfig);

  @visibleForTesting
  factory AikaAdManager.test({
    AikaAdPolicy? policy,
    AikaAdSdk? sdk,
    AiroAdUnitConfig unitConfig = const AiroAdUnitConfig(),
  }) {
    return AikaAdManager._(policy: policy, sdk: sdk, unitConfig: unitConfig);
  }

  static final AikaAdManager instance = AikaAdManager._();

  final AikaAdPolicy policy;
  final AikaAdSdk _sdk;
  final AiroAdPlacementEngine placementEngine;

  bool _sdkReady = false;
  Future<void>? _initializing;

  bool get isSdkReady => _sdkReady;

  Future<void> initialize({
    AiroDeviceFormFactor? formFactor,
    Future<AiroDeviceFormFactor> Function()? detectFormFactor,
  }) {
    if (kIsWeb || _sdkReady) {
      return Future<void>.value();
    }
    return _initializing ??= _initialize(
      formFactor: formFactor,
      detectFormFactor: detectFormFactor,
    );
  }

  Future<void> _initialize({
    AiroDeviceFormFactor? formFactor,
    Future<AiroDeviceFormFactor> Function()? detectFormFactor,
  }) async {
    final detected =
        formFactor ??
        await (detectFormFactor ?? () async => AiroDeviceFormFactor.mobile)();
    if (detected == AiroDeviceFormFactor.tv ||
        detected == AiroDeviceFormFactor.desktop) {
      return;
    }
    if (!await _sdk.initialize()) {
      return;
    }
    _sdkReady = true;
    policy.startSession();
  }

  bool shouldShowAd({required bool isLeanback, required bool isCasting}) {
    return policy.canShow(
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: _sdkReady,
    );
  }

  void recordAdImpression([DateTime? at, AiroAdFormat? format]) {
    policy.recordImpression(at, format);
  }
}

