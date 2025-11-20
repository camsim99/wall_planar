import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wall_planar/home_screen.dart';
import 'package:wall_planar/measure_debug_display.dart';

import 'main.dart' show sensorService;
import 'dart:async';

class MeasureView extends StatefulWidget {
  final VoidCallback onGoHome;

  const MeasureView({super.key, required this.onGoHome});

  @override
  State<MeasureView> createState() => _MeasureViewState();
}

class _MeasureViewState extends State<MeasureView> {
  // --- New State Variables for Slide Measure ---
  double _initialDistanceAccumulation = 0.0;
  double _finalDistanceAccumulation = 0.0;
  double _measuredUnits = 0.0; // The spacing between hooks in abstract units
  bool _isMeasuring = false;
  bool _isBottomSheetOpen = false;

  String _statusMessage =
      'Place phone against the wall at starting point then press START.';

  // CHANGED: Simulation constant now treats the result as a generic unit multiplier
  static const double unitsFactor = 1.0;

  // --- Stream Management ---
  final _distanceStreamController = StreamController<double>.broadcast();
  late final StreamSubscription _sensorSubscription;

  @override
  void initState() {
    super.initState();
    // Create one persistent subscription that lives as long as this widget.
    // This prevents the native stream from being cancelled when the bottom sheet closes.
    _sensorSubscription = sensorService.distanceAccumulationStream.listen((
      distance,
    ) {
      _distanceStreamController.add(distance);
    });
  }

  @override
  void dispose() {
    _sensorSubscription.cancel();
    _distanceStreamController.close();
    super.dispose();
  }

  void _startMeasurement(double currentAccumulation) {
    setState(() {
      _isMeasuring = true;
      _initialDistanceAccumulation = currentAccumulation;
      _finalDistanceAccumulation = 0.0;
      _measuredUnits = 0.0;
      _statusMessage = 'Slide phone horizontally to endpoint then press STOP.';
    });
  }

  void _stopMeasurement(double currentAccumulation) {
    if (!_isMeasuring) return;

    setState(() {
      _isMeasuring = false;
      _finalDistanceAccumulation = currentAccumulation;

      // Calculate the difference in accumulated motion units
      final unitsTraveled =
          _finalDistanceAccumulation - _initialDistanceAccumulation;

      // Calculate final measured units
      _measuredUnits = unitsTraveled * unitsFactor;

      _statusMessage = 'Measurement COMPLETE!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: StreamBuilder<double>(
          // Stream used only to show the live accumulation value while measuring
          stream: _distanceStreamController.stream,
          builder: (context, snapshot) {
            // Current value sent by native side (could be steps or integrated distance)
            final double liveAccumulation = snapshot.data ?? 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Back Button ---
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Status and Instructions ---
                          Container(
                            height:
                                70, // Give the text a fixed height to prevent layout shifts.
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                _statusMessage,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.getFont(
                                  'VT323',
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Measurement Result ---
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: Colors.black.withOpacity(0.9),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      _isMeasuring
                                          ? 'Measuring'
                                          : 'Final Spacing',
                                      style: GoogleFonts.getFont(
                                        'Press Start 2P',
                                        fontSize: 24,
                                        color: _isMeasuring
                                            ? Colors.blueAccent
                                            : Colors.red,
                                      ),
                                    ),
                                    Text(
                                      // Display final measurement or live distance if measuring
                                      (_isMeasuring
                                              ? (liveAccumulation -
                                                        _initialDistanceAccumulation)
                                                    .abs()
                                              : _measuredUnits)
                                          .toStringAsFixed(2),
                                      style: GoogleFonts.getFont(
                                        'VT323',
                                        color: Colors.green,
                                        fontSize: 72,
                                      ),
                                    ),
                                    Text(
                                      'Wall Units (WU)',
                                      style: GoogleFonts.getFont(
                                        'Press Start 2P',
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // --- Start/Stop Buttons ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Start Button
                                Opacity(
                                  opacity: _isMeasuring ? 0.4 : 1.0,
                                  child: GestureDetector(
                                    onTap: _isMeasuring
                                        ? null // Disable tap when measuring
                                        : () => _startMeasurement(
                                            liveAccumulation,
                                          ),
                                    child: Image.asset(
                                      'assets/start.png',
                                      width: 180,
                                    ),
                                  ),
                                ),
                                // Stop Button
                                Opacity(
                                  opacity: !_isMeasuring ? 0.4 : 1.0,
                                  child: GestureDetector(
                                    onTap: !_isMeasuring
                                        ? null // Disable tap when not measuring
                                        : () => _stopMeasurement(
                                            liveAccumulation,
                                          ),
                                    child: Image.asset(
                                      'assets/stop.png',
                                      width: 180,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // --- Show More Details Button ---
                // Center(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Back Button ---
                    GestureDetector(
                      onTap: widget.onGoHome,
                      child: Image.asset('assets/back.png', width: 60),
                    ),

                    SizedBox(width: 25),

                    Visibility(
                      visible: !_isBottomSheetOpen,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true,
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => _isBottomSheetOpen = true);

                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withOpacity(0.2),
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MeasureDebugDisplay(
                                    distanceStream: _distanceStreamController
                                        .stream, // Use the broadcast stream
                                    isMeasuring: _isMeasuring,
                                    initialDistance:
                                        _initialDistanceAccumulation,
                                  ),
                                ],
                              );
                            },
                          );

                          setState(() => _isBottomSheetOpen = false);
                        },
                        child: Image.asset(
                          'assets/show_more_details.png',
                          width: 150, // Corrected width for the button
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
