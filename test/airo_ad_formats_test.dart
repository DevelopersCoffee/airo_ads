import 'package:airo_ads/airo_ads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AikaAdPolicy Ad Format & Surface Tests', () {
    late DateTime now;
    late AikaAdPolicy policy;

    setUp(() {
      now = DateTime(2026, 9, 18, 12, 0, 0);
      policy = AikaAdPolicy(clock: () => now);
    });

    test('Session warmup denies ads before warmup duration', () {
      policy.startSession(now);

      final decision = policy.decideFormat(
        format: AiroAdFormat.banner,
        isWeb: false,
        isLeanback: false,
        isCasting: false,
        sdkReady: true,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, equals('warmup'));
    });

    test('Allows banner ad after warmup duration', () {
      policy.startSession(now.subtract(const Duration(minutes: 6)));

      final decision = policy.decideFormat(
        format: AiroAdFormat.banner,
        isWeb: false,
        isLeanback: false,
        isCasting: false,
        sdkReady: true,
      );

      expect(decision.allowed, isTrue);
      expect(decision.reason, equals('ok'));
    });

    test('TV / Leanback profile suppresses intrusive popup formats', () {
      policy.startSession(now.subtract(const Duration(minutes: 10)));

      for (final format in [
        AiroAdFormat.interstitial,
        AiroAdFormat.rewardedInterstitial,
        AiroAdFormat.appOpen,
        AiroAdFormat.banner,
      ]) {
        final decision = policy.decideFormat(
          format: format,
          isWeb: false,
          isLeanback: true,
          isCasting: false,
          sdkReady: true,
        );

        expect(
          decision.allowed,
          isFalse,
          reason: 'Format ${format.name} should be suppressed on Leanback TV',
        );
        expect(decision.reason, equals('leanback'));
      }
    });


    test('TV / Leanback profile permits non-intrusive pause & VAST ads', () {
      policy.startSession(now.subtract(const Duration(minutes: 10)));

      for (final format in [
        AiroAdFormat.pauseOverlay,
        AiroAdFormat.lowerThird,
        AiroAdFormat.vast,
      ]) {
        final decision = policy.decideFormat(
          format: format,
          isWeb: false,
          isLeanback: true,
          isCasting: false,
          sdkReady: true,
        );

        expect(decision.allowed, isTrue);
      }
    });

    test('Casting profile suppresses all ad formats', () {
      policy.startSession(now.subtract(const Duration(minutes: 10)));

      final decision = policy.decideFormat(
        format: AiroAdFormat.banner,
        isWeb: false,
        isLeanback: false,
        isCasting: true,
        sdkReady: true,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, equals('cast'));
    });
  });

  group('AiroAdUnitConfig Unit ID Resolution Tests', () {
    test('Resolves test unit IDs when aikaAdsUseTestUnits is true or default', () {
      const config = AiroAdUnitConfig();

      expect(config.resolvedBannerId, isNotEmpty);
      expect(config.resolvedInterstitialId, isNotEmpty);
      expect(config.resolvedRewardedId, isNotEmpty);
      expect(config.resolvedRewardedInterstitialId, isNotEmpty);
      expect(config.resolvedNativeId, isNotEmpty);
      expect(config.resolvedAppOpenId, isNotEmpty);
    });

    test('Custom ad unit IDs override defaults', () {
      const config = AiroAdUnitConfig(
        bannerAdUnitId: 'custom-banner-id',
        interstitialAdUnitId: 'custom-interstitial-id',
      );

      expect(config.resolvedBannerId, equals('custom-banner-id'));
      expect(config.resolvedInterstitialId, equals('custom-interstitial-id'));
    });
  });
}
