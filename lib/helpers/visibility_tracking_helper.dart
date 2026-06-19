class VisibilityTrackingHelper {
  const VisibilityTrackingHelper._();

  static const double impressionThreshold = 0.5;

  static bool shouldFireImpression({
    required double visibleFraction,
    required bool hasFired,
  }) {
    return !hasFired && visibleFraction >= impressionThreshold;
  }
}
