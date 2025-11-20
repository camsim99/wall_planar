import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    required Color accentColor,
    bool isPrimary = false,
  }) {
    final String formattedValue = value.toStringAsFixed(1);
    final bool isLevel = value.abs() < 1.0;
    final Color displayColor = isLevel ? Colors.lightGreenAccent : accentColor;

    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.getFont(
                'Press Start 2P',
                fontSize: isPrimary ? 14 : 10,
                color: displayColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$formattedValue°',
              style: GoogleFonts.getFont(
                'VT323',
                fontSize: isPrimary ? 40 : 28,
                color: Colors.white,
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

        return Container(
          // Semi-transparent background to ensure readability over the starfield
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            // border: const Border(
            //   top: BorderSide(color: Colors.white24, width: 2),
            // ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: _buildAngleCard(
                    title: 'Roll',
                    value: angles['roll']!,
                    accentColor: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 2, // Give the primary angle a bit more space
                  child: _buildAngleCard(
                    title: 'Pitch',
                    value: angles['pitch']!,
                    accentColor: Colors.blueAccent,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildAngleCard(
                    title: 'Yaw',
                    value: angles['yaw']!,
                    accentColor: Colors.redAccent.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
