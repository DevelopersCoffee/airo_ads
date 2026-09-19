import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../aika_ad_ids.dart';
import '../aika_ad_manager.dart';
import '../aika_ad_policy.dart';

/// App Open Ad Manager for app launch and background-to-foreground transitions.
class AiroAppOpenAdManager with WidgetsBindingObserver {
  AiroAppOpenAdManager({
    this.customAdUnitId,
    this.maxCacheDuration = const Duration(hours: 4),
  });

  final String? customAdUnitId;
  final Duration maxCacheDuration;

  AppOpenAd? _appOpenAd;
  DateTime? _loadTime;
  bool _isLoading = false;
  bool _isShowingAd = false;
  bool _isListening = false;

  /// Starts listening to app lifecycle changes for automatic App Open ad presentation.
  void startLifecycleListener() {
    if (_isListening) return;
    WidgetsBinding.instance.addObserver(this);
    _isListening = true;
    loadAd();
  }

  /// Stops listening to app lifecycle events.
  void stopLifecycleListener() {
    if (!_isListening) return;
    WidgetsBinding.instance.removeObserver(this);
    _isListening = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showAdIfAvailable();
    }
  }

  /// Pre-loads an App Open ad.
  Future<void> loadAd({
    bool isLeanback = false,
    bool isCasting = false,
  }) async {
    if (kIsWeb || _isLoading || isAdAvailable) return;

    await AikaAdManager.instance.initialize();

    final allowed = AikaAdManager.instance.policy.decideFormat(
      format: AiroAdFormat.appOpen,
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    ).allowed;

    if (!allowed) return;

    _isLoading = true;
    final adUnitId = customAdUnitId ??
        (const AiroAdUnitConfig()).resolvedAppOpenId;

    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _loadTime = DateTime.now();
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _appOpenAd = null;
          debugPrint('Airo App Open Ad failed to load: $error');
        },
      ),
    );
  }

  bool get isAdAvailable {
    return _appOpenAd != null &&
        _loadTime != null &&
        DateTime.now().difference(_loadTime!) < maxCacheDuration;
  }

  /// Displays the loaded App Open ad if available and allowed.
  Future<bool> showAdIfAvailable({
    bool isLeanback = false,
    bool isCasting = false,
    VoidCallback? onAdDismissed,
  }) async {
    if (kIsWeb || !isAdAvailable || _isShowingAd) {
      onAdDismissed?.call();
      if (!isAdAvailable && !_isLoading) {
        loadAd(isLeanback: isLeanback, isCasting: isCasting);
      }
      return false;
    }

    final allowed = AikaAdManager.instance.policy.decideFormat(
      format: AiroAdFormat.appOpen,
      isWeb: kIsWeb,
      isLeanback: isLeanback,
      isCasting: isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    ).allowed;

    if (!allowed) {
      onAdDismissed?.call();
      return false;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        AikaAdManager.instance.recordAdImpression(null, AiroAdFormat.appOpen);
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed?.call();
        loadAd(isLeanback: isLeanback, isCasting: isCasting);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        debugPrint('Airo App Open Ad failed to show: $error');
        onAdDismissed?.call();
        loadAd(isLeanback: isLeanback, isCasting: isCasting);
      },
    );

    await _appOpenAd!.show();
    return true;
  }

  /// Disposes resources.
  void dispose() {
    stopLifecycleListener();
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
