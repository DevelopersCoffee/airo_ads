/// Supported ad formats in airo_ads package.
enum AiroAdFormat {
  banner,
  interstitial,
  rewarded,
  rewardedInterstitial,
  native,
  appOpen,
  vast,
  lowerThird,
  pauseOverlay,
}

/// Frequency and surface rules for in-app native ads.
///
/// Pure Dart so tests do not need `google_mobile_ads`. Ads are in-app UI
/// only: never SSAI, never playlist rewriting, never Cast, never leanback popups.
class AikaAdPolicy {
  AikaAdPolicy({
    DateTime Function()? clock,
    this.sessionWarmup = const Duration(minutes: 5),
    this.cooldown = const Duration(minutes: 30),
    this.interstitialCooldown = const Duration(minutes: 3),
  }) : _clock = clock ?? DateTime.now;

  static const Duration defaultSessionWarmup = Duration(minutes: 5);
  static const Duration defaultCooldown = Duration(minutes: 30);
  static const Duration defaultInterstitialCooldown = Duration(minutes: 3);

  final DateTime Function() _clock;
  final Duration sessionWarmup;
  final Duration cooldown;
  final Duration interstitialCooldown;

  DateTime? _sessionStartedAt;
  DateTime? _lastImpressionAt;
  DateTime? _lastInterstitialImpressionAt;

  DateTime? get sessionStartedAt => _sessionStartedAt;
  DateTime? get lastImpressionAt => _lastImpressionAt;
  DateTime? get lastInterstitialImpressionAt => _lastInterstitialImpressionAt;

  void startSession([DateTime? at]) {
    _sessionStartedAt = at ?? _clock();
  }

  void recordImpression([DateTime? at, AiroAdFormat? format]) {
    final now = at ?? _clock();
    _lastImpressionAt = now;
    if (format == AiroAdFormat.interstitial ||
        format == AiroAdFormat.rewardedInterstitial) {
      _lastInterstitialImpressionAt = now;
    }
  }

  /// Evaluates whether an ad of a specific format can be displayed based on platform, policy, and state.
  AikaAdDecision decideFormat({
    required AiroAdFormat format,
    required bool isWeb,
    required bool isLeanback,
    required bool isCasting,
    bool sdkReady = true,
  }) {
    if (isWeb) {
      if (format != AiroAdFormat.vast &&
          format != AiroAdFormat.lowerThird &&
          format != AiroAdFormat.pauseOverlay) {
        return const AikaAdDecision.denied('web');
      }
    }

    if (isLeanback) {
      if (format != AiroAdFormat.pauseOverlay &&
          format != AiroAdFormat.lowerThird &&
          format != AiroAdFormat.vast) {
        return const AikaAdDecision.denied('leanback');
      }
    }

    if (isCasting) {
      return const AikaAdDecision.denied('cast');
    }

    if (!sdkReady && !isWeb) {
      return const AikaAdDecision.denied('sdk');
    }

    final sessionStart = _sessionStartedAt;
    if (sessionStart == null ||
        _clock().difference(sessionStart) < sessionWarmup) {
      return const AikaAdDecision.denied('warmup');
    }

    // Interstitial specific cooldown check
    if (format == AiroAdFormat.interstitial ||
        format == AiroAdFormat.rewardedInterstitial) {
      final lastInt = _lastInterstitialImpressionAt;
      if (lastInt != null &&
          _clock().difference(lastInt) < interstitialCooldown) {
        return const AikaAdDecision.denied('interstitial_cooldown');
      }
    }

    final lastImpression = _lastImpressionAt;
    if (lastImpression != null &&
        _clock().difference(lastImpression) < cooldown) {
      return const AikaAdDecision.denied('cooldown');
    }

    return const AikaAdDecision.allowed();
  }


  AikaAdDecision decide({
    required bool isWeb,
    required bool isLeanback,
    required bool isCasting,
    bool sdkReady = true,
  }) {
    return decideFormat(
      format: AiroAdFormat.native,
      isWeb: isWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: sdkReady,
    );
  }

  bool canShow({
    required bool isWeb,
    required bool isLeanback,
    required bool isCasting,
    bool sdkReady = true,
  }) {
    return decide(
      isWeb: isWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: sdkReady,
    ).allowed;
  }
}

class AikaAdDecision {
  const AikaAdDecision.allowed() : allowed = true, reason = 'ok';

  const AikaAdDecision.denied(this.reason) : allowed = false;

  final bool allowed;
  final String reason;
}

enum AikaAdPlacement { browse, pause }

