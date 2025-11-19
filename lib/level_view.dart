import 'package:flutter/material.dart';

import 'angle_display.dart';
import 'rotation_sensor_service.dart';

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
                'Rotation Vector Angles (Degrees)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
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

                  return AngleDisplay(angles: angles);
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'Hold phone flat on surface (Roll/Pitch should approach 0°)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
