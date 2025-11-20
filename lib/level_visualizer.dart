import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        : 'ADJUST $direction ${correctionAngle.toStringAsFixed(1)}°';
    return Column(
      children: [
        // --- Correction Text Display ---
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(
            correctionText,
            style: GoogleFonts.getFont(
              'Press Start 2P',
              fontSize: 20,
              color: isLevel ? Colors.lightGreenAccent : Colors.red,
            ),
          ),
        ),

        // --- The Rotating Image (Visualizing the Picture Frame Tilt) ---
        Transform.rotate(
          angle: angleInRadians,
          child: Image.asset(
            isLevel ? 'assets/level_perfect.png' : 'assets/level.png',
            width: 720, // Increased width
            height: 300, // Increased height
          ),
        ),
      ],
    );
  }
}
