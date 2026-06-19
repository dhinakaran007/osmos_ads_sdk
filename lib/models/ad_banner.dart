class AdBanner {
  const AdBanner({
    required this.imageUrl,
    required this.destinationUrl,
    required this.impressionTrackingUrl,
    required this.clickTrackingUrl,
  });

  final String imageUrl;
  final String destinationUrl;
  final String impressionTrackingUrl;
  final String clickTrackingUrl;

  String get trackingKey =>
      '$imageUrl|$impressionTrackingUrl|$clickTrackingUrl';

  factory AdBanner.fromJson(Map<dynamic, dynamic> json) {
    final elements = _readMap(json, 'elements');

    final imageUrl = _readRequiredString(elements, 'value');
    final impressionTrackingUrl = _readRequiredString(
      json,
      'impression_tracking_url',
    );
    final clickTrackingUrl = _readRequiredString(json, 'click_tracking_url');

    final destinationUrl =
        _readOptionalString(elements, 'destination_url') ??
        _readOptionalString(json, 'destination_url') ??
        _readRedirectUrl(clickTrackingUrl) ??
        clickTrackingUrl;

    _validateUri(imageUrl, 'Image URL');
    _validateUri(impressionTrackingUrl, 'Impression tracking URL');
    _validateUri(clickTrackingUrl, 'Click tracking URL');
    _validateUri(destinationUrl, 'Destination URL');

    return AdBanner(
      imageUrl: imageUrl,
      destinationUrl: destinationUrl,
      impressionTrackingUrl: impressionTrackingUrl,
      clickTrackingUrl: clickTrackingUrl,
    );
  }

  factory AdBanner.fromOsmosAd(Map<dynamic, dynamic> json) {
    return AdBanner.fromJson(json);
  }

  static Map<dynamic, dynamic> _readMap(Map<dynamic, dynamic> json, String key) {
    final value = json[key];

    if (value is Map) {
      return value;
    }

    throw FormatException('Missing or invalid object: $key');
  }

  static String _readRequiredString(Map<dynamic, dynamic> json, String key) {
    final value = json[key];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    throw FormatException('Missing or invalid field: $key');
  }

  static String? _readOptionalString(Map<dynamic, dynamic> json, String key) {
    final value = json[key];

    if (value is String && value.trim().isNotEmpty) {
      final trimmed = value.trim();

      if (trimmed.toLowerCase() == 'null') {
        return null;
      }

      return trimmed;
    }

    return null;
  }

  static String? _readRedirectUrl(String clickTrackingUrl) {
    final uri = Uri.tryParse(clickTrackingUrl);
    final redirectUrl = uri?.queryParameters['redirect_url'];

    if (redirectUrl == null ||
        redirectUrl.trim().isEmpty ||
        redirectUrl.toLowerCase() == 'null') {
      return null;
    }

    return redirectUrl.trim();
  }

  static void _validateUri(String value, String label) {
    final uri = Uri.tryParse(value);

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('$label is invalid.');
    }
  }
}
