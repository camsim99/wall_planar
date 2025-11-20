import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Placeholder/Target Views ---

class ThirdWidget extends StatelessWidget {
  const ThirdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Placeholder: Third Utility View',
        style: TextStyle(fontSize: 24, color: Colors.purpleAccent),
      ),
    );
  }
}

// --- Home Screen Implementation ---

// Define constants for navigation indices (must match main app's routing logic)
enum WallPlanarView { level, measure, third }

class HomeScreen extends StatelessWidget {
  // Callback function to inform the main app (WallPlanarApp) to change its view index.
  final ValueChanged<int> onNavigate;

  const HomeScreen({required this.onNavigate, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- App Logo / Schematic Image ---
              Column(
                children: [
                  // Using a placeholder image for the "WALL-PLANAR" schematic
                  // SizedBox(
                  //   height: 150,
                  //   width: 150,
                  // decoration: BoxDecoration(
                  //   color: Colors.blueGrey.shade100,
                  //   borderRadius: BorderRadius.circular(16),
                  //   border: Border.all(color: Colors.blueGrey.shade400),
                  // ),
                  Center(
                    child: Image.asset('assets/wall_planar.png', width: 700),
                  ),
                  // ),
                ],
              ),

              // const SizedBox(height: 20),

              // --- Navigation Buttons (Matching Retro Vibe) ---
              Column(
                children: [
                  _NavigationButton(
                    label: 'LEVEL VIEW',
                    icon: Icons.auto_fix_high,
                    color: Colors.redAccent, // Red button style
                    onPressed: () => onNavigate(0), // Level View is index 0
                  ),
                  const SizedBox(height: 16),
                  _NavigationButton(
                    label: 'MEASURE VIEW',
                    icon: Icons.straighten,
                    color: Colors.green, // Green button style
                    onPressed: () => onNavigate(1), // Measure View is index 1
                  ),
                  const SizedBox(height: 16),
                  _NavigationButton(
                    label: 'THIRD VIEW',
                    icon: Icons.extension,
                    color: Colors.blueGrey.shade600,
                    onPressed: () => onNavigate(2), // Third Widget is index 2
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget to mimic the retro button aesthetic
class _NavigationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          // Add a subtle border/shadow effect to mimic a retro button press state
          // side: BorderSide(color: color.withOpacity(0.8), width: 3),
        ),
        elevation: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.getFont(
              'Press Start 2P',
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
