import 'package:flutter/material.dart';
import 'package:wall_planar/rotation_sensor_service.dart';
import 'package:wall_planar/angle_display.dart';

import 'level_visualizer.dart';

class LevelView extends StatelessWidget {
  final RotationSensorService rotationSensorService = RotationSensorService();

  LevelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map<String, double>>(
        stream: rotationSensorService.eulerAngleStream,
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
                        const Text(
                          'Place phone standing up on the top edge of the picture frame.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.blueGrey.shade900,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AngleDisplay(angles: angles),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Show More Details',
                      style: TextStyle(color: Colors.white70),
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
}
