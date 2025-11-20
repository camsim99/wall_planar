import 'package:flutter/material.dart';

import 'level_view.dart';
import 'measure_view.dart';
import 'sensor_service.dart';

// Global SensorService.
final sensorService = SensorService();

void main() {
  runApp(const WallPlanarApp());
}

class WallPlanarApp extends StatelessWidget {
  const WallPlanarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WallPlanar Level View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // brightness: Brightness.light, // Dark mode aesthetic
        primarySwatch: Colors.blue,
        // fontFamily: 'Inter',
      ),
      home: MeasureView(), //LevelView(),
    );
  }
}
