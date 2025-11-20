import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wall_planar/rotation_sensor_service.dart';
import 'package:wall_planar/angle_display.dart';

import 'level_visualizer.dart';

class LevelView extends StatefulWidget {
  const LevelView({super.key});

  @override
  State<LevelView> createState() => _LevelViewState();
}

class _LevelViewState extends State<LevelView> {
  final _rotationSensorService = RotationSensorService();
  final _angleStreamController =
      StreamController<Map<String, double>>.broadcast();
  late final StreamSubscription _sensorSubscription;

  @override
  void initState() {
    super.initState();
    // Create one persistent subscription that lives as long as this widget.
    // This prevents the native stream from being cancelled when the bottom sheet closes.
    _sensorSubscription = _rotationSensorService.eulerAngleStream.listen((
      angles,
    ) {
      _angleStreamController.add(angles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map<String, double>>(
        stream: _angleStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error receiving sensor data: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // Use default or latest data
          final angles =
              snapshot.data ?? {'pitch': 0.0, 'roll': 0.0, 'yaw': 0.0};

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // This main column structures the whole screen
              children: [
                Expanded(
                  // Takes up all space above the button
                  child: Center(
                    // Centers its child in the expanded space
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Don't expand vertically
                      children: [
                        LevelVisualizer(
                          rollAngle: angles['roll']!,
                          pitchAngle: angles['pitch']!,
                          yawAngle: angles['yaw']!,
                        ),
                        Text(
                          'Place phone standing up on the top edge of the picture frame.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.getFont('VT323', fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.blueGrey.shade900,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            child: AngleDisplay(
                              angleStream: _angleStreamController.stream,
                            ),
                          );
                        },
                      );
                    },
                    child: Image.asset(
                      'assets/show_more_details.png',
                      width: 140, // Adjust size as needed
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _sensorSubscription.cancel();
    _angleStreamController.close();
    super.dispose();
  }
}
