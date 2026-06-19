import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../models/ad_banner.dart';
import 'osmos_sdk_service.dart';

class AdService {
  const AdService(this._osmosSdkService);

  final OsmosSdkService _osmosSdkService;

  Future<AdBanner> fetchBannerAd() async {
    final response = await _osmosSdkService.fetchDisplayAds();
    // debugPrint('response in the service: $response');
    final ads = jsonDecode(response['data']);
    debugPrint(ads.runtimeType.toString());
    // debugPrint('ads in the service: $ads');
    if (ads is! Map<String, dynamic>) {
      throw const FormatException('Ad response does not contain ads.');
    }

    final bannerAds = ads['ads'];
    final enrichedAds = bannerAds['banner_ads'];
    if (enrichedAds is! List || enrichedAds.isEmpty) {
      throw const FormatException('Ad not available.');
    }

    final firstAd = enrichedAds.first;
    debugPrint('first ad: $firstAd');
    if (firstAd is! Map<String, dynamic>) {
      throw const FormatException('First banner ad is invalid.');
    }

    return AdBanner.fromOsmosAd(firstAd);
  }
}
