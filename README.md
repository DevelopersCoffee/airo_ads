# airo_ads

[![pub package](https://img.shields.io/pub/v/airo_ads.svg)](https://pub.dev/packages/airo_ads)
[![CI](https://github.com/DevelopersCoffee/airo_ads/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/airo_ads/actions)
[![GitHub Pages](https://img.shields.io/badge/Docs-GitHub%20Pages-38bdf8)](https://developerscoffee.github.io/airo_ads/)
[![Publisher](https://img.shields.io/badge/publisher-developerscoffee.com-blue)](https://pub.dev/publishers/developerscoffee.com/packages)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Google Mobile Ads SDK wrapper, in-app AdMob Native card widgets, non-intrusive Pause Ads, lower-third overlays, and zero-dependency VAST/VMAP ad tag parser for Flutter apps.

Part of the **[DevelopersCoffee](https://developerscoffee.com)** open-source ecosystem.

🌐 **Interactive Documentation & Live Preview**: [https://developerscoffee.github.io/airo_ads/](https://developerscoffee.github.io/airo_ads/)

---

## ✨ AI Agent Skill Prompt (`skill.sh` compatible)

If you are using AI coding assistants (Antigravity, Cursor, Claude, Copilot, etc.), copy and execute the prompt below to load standardized Flutter architecture instructions:

```bash
Run `npx skills use "https://github.com/flutter/agent-plugins" --skill "flutter-apply-architecture-best-practices"`
```

---

## Features

- **Full AdMob Ad Formats Suite**:
  - `AiroBannerAdWidget`: Anchored Adaptive, Inline Adaptive, Standard, and Collapsible Banners (`top` / `bottom`).
  - `AiroInterstitialAdManager`: Pre-fetching Interstitial ads with policy gating.
  - `AiroRewardedAdManager`: Rewarded Video & Rewarded Interstitial ads with completion reward callbacks.
  - `AiroAppOpenAdManager`: App launch and background-to-foreground return ads.
  - `AikaNativeAdCard`: Responsive Small/Medium Native Advanced cards.
- **Intelligent Placement Engine (`AiroAdPlacementEngine`)**: Dynamic contextual ad placement routing with automatic platform and form-factor awareness (Mobile, Tablet, TV, Desktop, Web, Cast).
- **Frequency Policy Engine**: Pure Dart `AikaAdPolicy` enforcing session warmup (5 minutes ad-free) and impression cooldowns.
- **In-Stream Non-Intrusive Overlays**:
  - `AiroPauseAdOverlay`: Displays elegant high-res ad cards when video streams are paused without interrupting audio or playback state.
  - `AiroLowerThirdOverlayAd`: Translucent non-linear lower-third overlay banner fading into the bottom 20% of the viewport.
- **VAST / VMAP Ad Tag Integration**:
  - `AiroVastAdTag`: Helper to construct Google Ad Manager (GAM) VAST endpoints.
  - `AiroVastTagParser`: Zero-dependency VAST XML parser extracting ad systems, titles, impressions, and media file URLs.
- **Zero-Crash Safe Stubs**: Automatically safe on web, TV, desktop, and casting sessions.

---

## Getting Started

Add `airo_ads` to your `pubspec.yaml`:

```yaml
dependencies:
  airo_ads: ^1.1.0
```

Initialize `AikaAdManager` at app launch:

```dart
import 'package:airo_ads/airo_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AikaAdManager.instance.initialize();
  runApp(const MyApp());
}
```

---

## Usage

### In-Stream Pause Ad Overlay

Wrap your video player viewport with `AiroPauseAdOverlay`:

```dart
AiroPauseAdOverlay(
  isPaused: isVideoPaused,
  child: VideoPlayerView(),
)
```

### Non-Linear Lower-Third Overlay

Display translucent lower-third banners during live matches or streaming without stopping video playback:

```dart
AiroLowerThirdOverlayAd(
  adTitle: 'Live Match Sponsor',
  adDescription: 'Tap to view exclusive streaming deals',
  displayDuration: const Duration(seconds: 10),
  onAdDismissed: () => print('Ad closed'),
)
```

### Google GAM VAST Ad Tags

Construct GAM VAST tag URLs or parse VAST XML responses:

```dart
final tag = AiroVastAdTag.googleAdManager(
  adUnitPath: '/1234567/sports_live',
  descriptionUrl: 'https://developerscoffee.com',
);

final parsed = AiroVastTagParser.parseXml(
  tagUrl: tag.tagUrl,
  xmlContent: rawXmlString,
);
```

---

## Custom Feature Requests, Contributions & Technical Support

At **DevelopersCoffee**, we are building technical assets for the developer community and enterprises worldwide.

- 🐛 **Bug Reports & Feature Requests**: Open an issue or pull request on our [GitHub Repository](https://github.com/DevelopersCoffee/airo_ads/issues).
- 🤝 **Community Contributions**: We welcome open-source contributions! Feel free to pick up open issues or submit new components.
- 💼 **Enterprise Consulting & Custom Development**: If your team needs custom library components, high-performance video streaming optimizations, or tailored Flutter/Rust development, reach out to us at **[developerscoffee.com](https://developerscoffee.com)**.

---

## Maintainers

Maintained with ❤️ by **[DevelopersCoffee](https://developerscoffee.com)**.
