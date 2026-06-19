import 'package:flutter/material.dart';
import 'package:osmos_retail_media/services/osmos_sdk_service.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OsmosSdkService.initialize();
  runApp(const OsmosAdsApp());
}

class OsmosAdsApp extends StatelessWidget {
  const OsmosAdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Osmos Ads Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}
