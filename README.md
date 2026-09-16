# airo_ads

[![pub package](https://img.shields.io/pub/v/airo_ads.svg)](https://pub.dev/packages/airo_ads)
[![CI](https://github.com/DevelopersCoffee/airo_ads/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/airo_ads/actions)
[![Publisher](https://img.shields.io/badge/publisher-developerscoffee.com-blue)](https://pub.dev/publishers/developerscoffee.com/packages)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Google Mobile Ads SDK wrapper, in-app AdMob Native card widgets, non-intrusive Pause Ads, lower-third overlays, and VAST/VMAP ad tag parser for Flutter apps.

Part of the **DevelopersCoffee** open-source ecosystem.

---

## Features

- **Frequency Policy Engine**: Pure Dart `AikaAdPolicy` enforcing session warmup (5 minutes ad-free) and impression cooldowns (30 minutes between ads).
- **Native Card Widgets**: `AikaNativeAdCard` responsive small/medium layout templates with automatic dark mode color scheme matching and silent fail on no-fill.
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
  airo_ads: ^1.0.0
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

## Maintainers

Maintained with ❤️ by **[DevelopersCoffee](https://developerscoffee.com)**.
