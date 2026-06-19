import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ad_banner.dart';
import '../helpers/visibility_tracking_helper.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/osmos_sdk_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnalyticsService _analyticsService = const AnalyticsService();

  late final OsmosSdkService _osmosSdkService;
  late final AdService _adService;

  AdBanner? _ad;
  String _status = 'Ready to load an ad.';
  String? _errorMessage;
  bool _isFetching = false;
  bool _hasFiredImpression = false;

  @override
  void initState() {
    super.initState();
    _osmosSdkService = OsmosSdkService(analyticsService: _analyticsService);
    _adService = AdService(_osmosSdkService);
  }

  Future<void> _loadAd() async {
    if (_isFetching) {
      return;
    }

    setState(() {
      _isFetching = true;
      _errorMessage = null;
      _status = 'Fetching banner ad...';
    });

    try {
      final ad = await _adService.fetchBannerAd();
      if (!mounted) {
        return;
      }
      setState(() {
        _ad = ad;
        _hasFiredImpression = false;
        _status = 'Ad Loaded';
      });
      _analyticsService.logAdLoaded();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _ad = null;
        _errorMessage = 'Ad not available';
        _status = 'Ad Failed';
      });
      _analyticsService.logAdFailed(error);
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  Future<void> _fireImpression(double visibleFraction) async {
    final ad = _ad;
    if (!VisibilityTrackingHelper.shouldFireImpression(
          visibleFraction: visibleFraction,
          hasFired: _hasFiredImpression,
        ) ||
        ad == null) {
      return;
    }

    setState(() {
      _hasFiredImpression = true;
      _status = 'Impression Fired';
    });

    try {
      await _osmosSdkService.fireImpression();
      _analyticsService.logImpressionFired();
    } catch (error) {
      _analyticsService.logAdFailed(error);
    }
  }

  Future<void> _handleAdClick() async {
    final ad = _ad;
    if (ad == null) {
      return;
    }

    setState(() {
      _status = 'Click Fired';
    });

    try {
      await _osmosSdkService.fireClick();
      _analyticsService.logClickFired();

      final destinationUri = Uri.parse(ad.destinationUrl);
      final launched = await launchUrl(
        destinationUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        setState(() {
          _status = 'Unable to open destination URL.';
        });
      }
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _status = 'Click failed.';
        });
      }
      debugPrint('Ad click failed: $error');
      debugPrint('Ad click stack trace: $stackTrace');
      _analyticsService.logAdFailed(error);
    }
  }

  @override
  void dispose() {
    _osmosSdkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Osmos Ads Demo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FilledButton.icon(
              onPressed: _isFetching ? null : _loadAd,
              icon: const Icon(Icons.campaign),
              label: Text(_isFetching ? 'Loading...' : 'Load Ad'),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(minHeight: 220),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: _buildBannerContent(),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _status,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerContent() {
    if (_isFetching) {
      return const LoadingWidget();
    }

    if (_errorMessage != null) {
      return AdErrorWidget(message: _errorMessage!, onRetry: _loadAd);
    }

    final ad = _ad;
    if (ad == null) {
      return Text(
        'Ad not loaded',
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }

    return BannerAdWidget(
      ad: ad,
      hasFiredImpression: _hasFiredImpression,
      onImpressionReady: _fireImpression,
      onTap: _handleAdClick,
    );
  }
}
