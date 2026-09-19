import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../aika_ad_ids.dart';
import '../aika_ad_manager.dart';
import '../aika_ad_policy.dart';

/// Banner ad presentation style variants.
enum AiroBannerStyle {
  standard,
  anchoredAdaptive,
  inlineAdaptive,
  collapsibleBottom,
  collapsibleTop,
}

/// Smart Banner Widget with Anchored Adaptive, Inline Adaptive, and Collapsible Banner support.
class AiroBannerAdWidget extends StatefulWidget {
  const AiroBannerAdWidget({
    super.key,
    this.bannerStyle = AiroBannerStyle.anchoredAdaptive,
    this.customAdUnitId,
    this.isLeanback = false,
    this.isCasting = false,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  final AiroBannerStyle bannerStyle;
  final String? customAdUnitId;
  final bool isLeanback;
  final bool isCasting;
  final VoidCallback? onAdLoaded;
  final void Function(LoadAdError error)? onAdFailedToLoad;

  @override
  State<AiroBannerAdWidget> createState() => _AiroBannerAdWidgetState();
}

class _AiroBannerAdWidgetState extends State<AiroBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (kIsWeb) return;
    await AikaAdManager.instance.initialize();
    if (!mounted) return;

    final allowed = AikaAdManager.instance.policy.decideFormat(
      format: AiroAdFormat.banner,
      isWeb: kIsWeb,
      isLeanback: widget.isLeanback,
      isCasting: widget.isCasting,
      sdkReady: AikaAdManager.instance.isSdkReady,
    ).allowed;

    if (!allowed) return;

    final adUnitId = widget.customAdUnitId ??
        (const AiroAdUnitConfig()).resolvedBannerId;

    final adSize = await _getAdSize();
    if (!mounted || adSize == null) return;

    final request = _buildAdRequest();

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isAdLoaded = true;
          });
          widget.onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Airo Banner Ad failed to load: $error');
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
            });
            widget.onAdFailedToLoad?.call(error);
          }
        },
        onAdImpression: (ad) {
          AikaAdManager.instance.recordAdImpression(
            null,
            AiroAdFormat.banner,
          );
        },
      ),
    )..load();
  }

  AdRequest _buildAdRequest() {
    if (widget.bannerStyle == AiroBannerStyle.collapsibleBottom) {
      return const AdRequest(extras: {'collapsible': 'bottom'});
    } else if (widget.bannerStyle == AiroBannerStyle.collapsibleTop) {
      return const AdRequest(extras: {'collapsible': 'top'});
    }
    return const AdRequest();
  }

  Future<AdSize?> _getAdSize() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    switch (widget.bannerStyle) {
      case AiroBannerStyle.standard:
        return AdSize.banner;
      case AiroBannerStyle.anchoredAdaptive:
      case AiroBannerStyle.collapsibleBottom:
      case AiroBannerStyle.collapsibleTop:
        return await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          width,
        );
      case AiroBannerStyle.inlineAdaptive:
        return AdSize.getInlineAdaptiveBannerAdSize(width, 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Advertisement Banner',
      child: Center(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
