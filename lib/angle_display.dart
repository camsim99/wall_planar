import 'package:flutter/material.dart';

class AngleDisplay extends StatefulWidget {
  final Stream<Map<String, double>> angleStream;

  const AngleDisplay({required this.angleStream, super.key});

  @override
  State<AngleDisplay> createState() => _AngleDisplayState();
}

class _AngleDisplayState extends State<AngleDisplay> {
  Widget _buildAngleCard({
    required String title,
    required double value,
    required Color color,
  }) {
    // Format to 2 decimal places and ensure 0.0 is shown correctly
    final String formattedValue = value.toStringAsFixed(2);

    // Check if close to 0 (level)
    final bool isLevel = value.abs() < 1.0;

    return Card(
      color: Colors.blueGrey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLevel ? Colors.lightGreenAccent : color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$formattedValue°',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isLevel ? Colors.lightGreenAccent : Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: widget.angleStream,
      builder: (context, snapshot) {
        final angles = snapshot.data ?? {'roll': 0.0, 'pitch': 0.0, 'yaw': 0.0};

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Roll (X-axis) - Side to side tilt
            _buildAngleCard(
              title: 'Roll (X-Axis)',
              value: angles['roll']!,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            // Pitch (Y-axis) - Forward/backward tilt
            _buildAngleCard(
              title: 'Pitch (Y-Axis)',
              value: angles['pitch']!,
              color: Colors.cyanAccent,
            ),
            const SizedBox(height: 8),
            // Yaw (Z-axis) - Compass heading (less critical for leveling)
            _buildAngleCard(
              title: 'Yaw (Z-Axis)',
              value: angles['yaw']!,
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 16), // Add some padding at the bottom
          ],
        );
      },
    );
  }
}
