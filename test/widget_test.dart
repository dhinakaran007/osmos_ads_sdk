import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:osmos_retail_media/main.dart';

void main() {
  testWidgets('Home screen renders load ad flow', (WidgetTester tester) async {
    await tester.pumpWidget(const OsmosAdsApp());

    expect(find.text('Osmos Ads Demo'), findsOneWidget);
    expect(find.text('Load Ad'), findsOneWidget);
    expect(find.text('Ad not loaded'), findsOneWidget);
    expect(find.byIcon(Icons.campaign), findsOneWidget);
  });
}
