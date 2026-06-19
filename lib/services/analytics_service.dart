import 'package:flutter/foundation.dart';

class AnalyticsService {
  const AnalyticsService();

  void logAdLoaded() => _log('Ad Loaded');

  void logAdFailed(Object error) => _log('Ad Failed: $error');

  void logImpressionFired() => _log('Impression Fired');

  void logImpressionFailed(String exceptionMessage) => _log('Impression Failed: $exceptionMessage');
 
  void logClickFired() => _log('Click Fired');

  void adClieckEventFired() => _log('Ad click event fired');

  void error(String e) => _log('error: $e'); 

  void _log(String message) {
    debugPrint('[OsmosAnalytics] $message');
  }
}
