import 'package:flutter/material.dart';
import 'package:wall_planar/rotation_sensor_service.dart';

import 'level_visualizer.dart';

class LevelView extends StatelessWidget {
  final RotationSensorService rotationSensorService = RotationSensorService();

  LevelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WallPlanar: Level View'),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Picture Level Assistant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // StreamBuilder listens to the processed angle data
              StreamBuilder<Map<String, double>>(
                stream: rotationSensorService.eulerAngleStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error receiving sensor data: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    );
                  }

                  // Use default or latest data
                  final angles =
                      snapshot.data ?? {'pitch': 0.0, 'roll': 0.0, 'yaw': 0.0};

                  // Only use Roll for the horizontal level visualization
                  return LevelVisualizer(
                    rollAngle: angles['roll']!,
                    pitchAngle:
                        angles['pitch']!, // Still pass Pitch for secondary info
                    yawAngle:
                        angles['yaw']!, // Still pass Yaw for secondary info
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'Place phone standing up on the top edge of the picture frame.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
