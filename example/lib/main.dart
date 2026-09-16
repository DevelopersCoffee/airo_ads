import 'package:airo_ads/airo_ads.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AikaAdManager.instance.initialize();
  runApp(const AiroAdsExampleApp());
}

class AiroAdsExampleApp extends StatelessWidget {
  const AiroAdsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airo Ads Example',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  bool _isPaused = false;
  bool _showLowerThird = false;
  String _vastStatus = 'Not generated';

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _triggerLowerThird() {
    setState(() {
      _showLowerThird = true;
    });
  }

  void _generateVast() {
    final tag = AiroVastAdTag.googleAdManager(
      adUnitPath: '/1234567/sports_live',
      descriptionUrl: 'https://developerscoffee.com',
    );
    setState(() {
      _vastStatus = 'Generated GAM VAST URL:\n${tag.tagUrl}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Airo Ads Demo')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Video Player Viewport Sim',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          color: Colors.black87,
                          alignment: Alignment.center,
                          child: AiroPauseAdOverlay(
                            isPaused: _isPaused,
                            child: Center(
                              child: Icon(
                                _isPaused
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _togglePause,
                          icon: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                          ),
                          label: Text(
                            _isPaused ? 'Resume Video' : 'Pause Video',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'In-Stream Non-Linear Lower-Third Ad',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _triggerLowerThird,
                          icon: const Icon(Icons.campaign),
                          label: const Text(
                            'Trigger Lower-Third Overlay (10s)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'VAST / VMAP Ad Tag Generator',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _generateVast,
                          icon: const Icon(Icons.link),
                          label: const Text('Generate Google GAM VAST Tag'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _vastStatus,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showLowerThird)
            AiroLowerThirdOverlayAd(
              adTitle: 'DevelopersCoffee Stream Deals',
              adDescription: 'Save 20% on developer tools and IPTV extensions',
              displayDuration: const Duration(seconds: 10),
              onAdDismissed: () {
                setState(() {
                  _showLowerThird = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
