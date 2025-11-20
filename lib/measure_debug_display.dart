import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeasureDebugDisplay extends StatelessWidget {
  final Stream<double> distanceStream;
  final bool isMeasuring;
  final double initialDistance;

  const MeasureDebugDisplay({
    super.key,
    required this.distanceStream,
    required this.isMeasuring,
    required this.initialDistance,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: distanceStream,
      builder: (context, snapshot) {
        final liveAccumulation = snapshot.data ?? 0.0;
        return Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${isMeasuring ? "ACTIVE SLIDE" : "INACTIVE"}',
                style: GoogleFonts.getFont(
                  'Press Start 2P',
                  fontSize: 14,
                  color: isMeasuring ? Colors.blueAccent : Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total Units (WU): ${liveAccumulation.toStringAsFixed(2)}',
                style: GoogleFonts.getFont(
                  'VT323',
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start Unit (WU): ${initialDistance.toStringAsFixed(2)}',
                style: GoogleFonts.getFont(
                  'VT323',
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
