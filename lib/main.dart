import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'level_view.dart';
import 'measure_view.dart';
import 'sensor_service.dart';

// Global SensorService.
final sensorService = SensorService();

void main() {
  runApp(const WallPlanarApp());
}

class WallPlanarApp extends StatefulWidget {
  const WallPlanarApp({super.key});

  @override
  State<WallPlanarApp> createState() => _WallPlanarAppState();
}

class _WallPlanarAppState extends State<WallPlanarApp> {
  // Start on a unique index for the HomeScreen (index 3)
  int _selectedIndex = 3;

  // Map of views based on their navigation index (Indices 0, 1, 2 for utilities)
  late final List<Widget> _utilityViews;

  // Callback used by the HomeScreen buttons to transition to a functional view.
  void _onNavigateToUtility(int index) {
    if (index >= 0 && index < _utilityViews.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // --- Utility Methods ---

  // Called when the user taps an item on the BottomNavigationBar

  // Called when the user taps the back button/icon on a utility view
  void _goHome() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  @override
  void initState() {
    super.initState();
    _utilityViews = <Widget>[
      LevelView(onGoHome: _goHome),
      MeasureView(onGoHome: _goHome),
      const ThirdWidget(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Show the HomeScreen if _selectedIndex is 3
    final bool isHome = _selectedIndex == 3;
    final Widget currentView = isHome
        ? HomeScreen(onNavigate: _onNavigateToUtility)
        : _utilityViews.elementAt(_selectedIndex);

    return MaterialApp(
      title: 'WallPlanar Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        // primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/grid.png"),
            fit: BoxFit.cover, // Stretch the image to cover the screen
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.7), // Adjust the color and opacity
              BlendMode.lighten, // Or BlendMode.dstIn
            ),
          ),
        ),
        child: WillPopScope(
          onWillPop: () async {
            if (!isHome) {
              _goHome();
              return false; // Prevent default back behavior
            }
            return true; // Allow exit if already on home screen
          },
          child: currentView,
        ),
      ),
    );
  }
}
