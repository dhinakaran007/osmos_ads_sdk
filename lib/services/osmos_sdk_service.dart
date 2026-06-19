import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:osmos_flutter_plugin/core/osmos.dart';
import 'package:osmos_flutter_plugin/models/targeting_params.dart';
import 'package:osmos_flutter_plugin/models/tracking_params.dart';
import 'package:osmos_retail_media/services/analytics_service.dart';

class OsmosSdkService {
  OsmosSdkService({
    required this.analyticsService,
    http.Client? client
    }) : _client = client ?? http.Client();

  static const String clientId = '10088010';
  static const String productAdsHost = 'demo.o-s.io';
  static const String displayAdsHost = 'demo-ba.o-s.io';
  static const String cliUbid = 'Any';
  static const String pageType = 'demo_page';
  static const String adUnit = 'banner_ads';

  final AnalyticsService analyticsService;

  final http.Client _client;

  static Future<void> initialize() async {

    await OsmosSDK.clientId(clientId)
      .debug(false)
      .eventTrackingHost("custom-events.example.com") 
      .displayAdsHost(displayAdsHost)   
      .productAdsHost(productAdsHost)       
      .buildGlobalInstance();

  }

  static OsmosSDK get sdk => OsmosSDK.globalInstance();
  static dynamic get adFetcher => sdk.adFetcher;
  static dynamic get registerEvent => sdk.registerEvent;

  final target = [
    ContextTargeting.keyword("chocolate")
  ];

  Future<dynamic> fetchDisplayAds() async {

    try {
      final response = await adFetcher.fetchDisplayAdsWithAu(
      cliUbid: cliUbid,
      pageType: pageType,
      productCount: 1,
      adUnits: [adUnit],
      targetingParams: target,
      );

      if (response != null && response['status'] == true) {
        // debugPrint('response: $response');
        return response['response'];
      }

      debugPrint('failed response: $response');
      return null;
    } catch (e) {
      analyticsService.logAdFailed(e);
      return null;
    }
  }

  Future<void> fireImpression() async {
    try {
      final response = await registerEvent.registerAdImpressionEvent(
        cliUbid: cliUbid,
        uclid: cliUbid,
        position: 1
      );

      if (response != null && response['status'] == true) {
        analyticsService.logImpressionFired();
      }
    } catch (e) {
      analyticsService.logImpressionFailed(e.toString());
    }
  }

  Future<void> fireClick() {
    return _fireTrackingEvent();
  }

  Future<void> _fireTrackingEvent() async {
    try {
      final params = TrackingParams.builder().sellerId("1321cs1").build();

      final response = await registerEvent.registerAdClickEvent(
        cliUbid: cliUbid,
        uclid: cliUbid,
        trackingParams: params,
      );

      if (response != null && response['status'] == true) {
        analyticsService.adClieckEventFired();
      }
    } catch (e) {
      analyticsService.error(e.toString());
    }
    
  }

  void dispose() {
    _client.close();
  }
}
