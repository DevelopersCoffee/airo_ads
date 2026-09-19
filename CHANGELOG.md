# CHANGELOG

## 1.1.0

- Added comprehensive support for all Google AdMob ad formats:
  - Anchored Adaptive, Inline Adaptive, Standard, and Collapsible Banners (`AiroBannerAdWidget`).
  - Pre-fetching Interstitial Ads (`AiroInterstitialAdManager`).
  - Rewarded & Rewarded Interstitial Ads with completion callbacks (`AiroRewardedAdManager`).
  - App Open Ads bound to app background/foreground lifecycle events (`AiroAppOpenAdManager`).
- Introduced `AiroAdPlacementEngine` for intelligent, context-aware placement decisions (`bannerFooter`, `bannerInline`, `screenTransition`, `rewardedAction`, `appLaunch`, `nativeCard`, `pauseOverlay`, `lowerThird`).
- Expanded `AiroAdUnitConfig` supporting customizable Android & iOS Ad Unit IDs per format.
- Enhanced platform-aware policy rules suppressing intrusive popups on TV / Leanback and Cast profiles while maintaining non-disruptive player overlays and VAST tags.

## 1.0.0


- Initial release of `airo_ads` under `DevelopersCoffee`.
- In-app AdMob Native Advanced card widgets (`AikaNativeAdCard`).
- Non-intrusive Pause Ads overlay widget (`AiroPauseAdOverlay`).
- Non-linear lower-third overlay banner widget (`AiroLowerThirdOverlayAd`).
- Unified VAST 4.x / VMAP Ad Tag URL builder and XML parser (`AiroVastAdTag`, `AiroVastTagParser`, `AiroUnifiedPlayerAdAdapter`).
- Frequency capping engine (`AikaAdPolicy`) enforcing 5-minute session warmup and 30-minute impression cooldown.
- Cross-platform web and desktop SDK initialization guards (`AikaAdSdk`).
