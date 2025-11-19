import 'dart:math';

import 'package:flutter/material.dart';

class LevelVisualizer extends StatelessWidget {
  final double rollAngle;
  final double pitchAngle;
  final double yawAngle;

  // Define tolerance for snapping and showing 'Level' status
  static const double levelTolerance =
      0.5; // Snap if tilt is less than 0.5 degrees

  const LevelVisualizer({
    required this.rollAngle,
    required this.pitchAngle,
    required this.yawAngle,
    super.key,
  });

  // Convert degrees to radians for Flutter's Transform.rotate
  double _degreesToRadians(double degrees) => degrees * (pi / 180.0);

  @override
  Widget build(BuildContext context) {
    // --- CRITICAL CHANGE: Use PITCH for the Leveling Angle ---

    // 1. Apply snapping filter: If within tolerance, snap to 0.0
    final isLevel = pitchAngle.abs() < levelTolerance;
    final primaryAngle = pitchAngle; // The input angle is Pitch
    final displayAngle = isLevel ? 0.0 : primaryAngle;
    final angleInRadians = _degreesToRadians(displayAngle);

    // 2. Determine correction text and color
    final double correctionAngle = primaryAngle.abs();

    // Roll > 0 means the right side is higher (needs adjustment DOWN to the right, or UP to the left)
    // Pitch > 0 means the right side is lower (needs adjustment UP to the right) when standing.
    final String direction = primaryAngle > 0 ? 'LEFT' : 'RIGHT';

    final correctionText = isLevel
        ? 'PERFECTLY LEVEL'
        : 'ADJUST $direction: ${correctionAngle.toStringAsFixed(1)}°';

    final correctionColor = isLevel
        ? Colors.lightGreenAccent
        : Colors.redAccent;

    return Column(
      children: [
        // --- Correction Text Display ---
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(
            correctionText,
            style: TextStyle(
              fontSize: isLevel ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: correctionColor,
            ),
          ),
        ),

        // --- Visualization Container ---
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueGrey.shade700, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            // --- The Rotating Line (Visualizing the Picture Frame Tilt) ---
            child: Transform.rotate(
              angle: angleInRadians,
              child: Container(
                width: 280,
                height: 40,
                decoration: BoxDecoration(
                  color: isLevel ? Colors.lightGreen : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Picture Frame',
                  style: TextStyle(
                    color: isLevel ? Colors.black : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- Numerical Pitch/Roll/Yaw (For secondary info/debugging) ---
        const SizedBox(height: 20),

        // Roll (X-axis tilt) is now the side-to-side tilt (ignored for leveling)
        Text(
          'Roll (X-Axis Tilt): ${rollAngle.toStringAsFixed(2)}° (Ignored for Leveling)',
          style: const TextStyle(color: Colors.orange, fontSize: 16),
        ),
        // Pitch (Y-axis tilt) is the main angle displayed above
        Text(
          'Pitch (Y-Axis Tilt): ${pitchAngle.toStringAsFixed(2)}° (Primary Angle)',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Yaw (Z-axis heading) is still the heading
        Text(
          'Yaw (Z-Axis Heading): ${yawAngle.toStringAsFixed(2)}°',
          style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
        ),
      ],
    );
  }
}
