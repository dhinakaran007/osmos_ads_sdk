import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../helpers/visibility_tracking_helper.dart';
import '../models/ad_banner.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({
    required this.ad,
    required this.hasFiredImpression,
    required this.onImpressionReady,
    required this.onTap,
    super.key,
  });

  final AdBanner ad;
  final bool hasFiredImpression;
  final VoidCallback onImpressionReady;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return VisibilityDetector(
      key: ValueKey('banner-ad-${ad.trackingKey}'),
      onVisibilityChanged: (info) {
        if (VisibilityTrackingHelper.shouldFireImpression(
          visibleFraction: info.visibleFraction,
          hasFired: hasFiredImpression,
        )) {
          onImpressionReady();
        }
      },
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              ad.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'Ad image unavailable',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
