import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Model for Draggable Boxes ---
class PictureFrame {
  final Key key;
  final double width;
  final double height;
  final Color color;
  Offset position; // Position relative to the top-left of the canvas

  PictureFrame({
    required this.width,
    required this.height,
    required this.color,
    required this.position,
  }) : key = UniqueKey();
}

// --- Frame Types for the Drawer ---
final List<PictureFrame> _frameTemplates = [
  PictureFrame(
    width: 80,
    height: 120,
    color: Colors.blueGrey.shade400,
    position: Offset.zero,
  ),
  PictureFrame(
    width: 150,
    height: 100,
    color: Colors.orange.shade400,
    position: Offset.zero,
  ),
  PictureFrame(
    width: 100,
    height: 100,
    color: Colors.lightGreen.shade400,
    position: Offset.zero,
  ),
];

// NOTE: ThirdWidget is removed, as requested.
// The main router will now directly reference LayoutPlannerView.

class LayoutPlannerView extends StatefulWidget {
  final VoidCallback onGoHome;
  const LayoutPlannerView({super.key, required this.onGoHome});

  @override
  State<LayoutPlannerView> createState() => _LayoutPlannerViewState();
}

class _LayoutPlannerViewState extends State<LayoutPlannerView> {
  List<PictureFrame> _frames = [];
  Offset _trashDropArea = Offset.zero; // Tracks the center of the trash can

  // --- Actions ---

  void _clearCanvas() {
    setState(() {
      _frames.clear();
    });
  }

  void _addFrame(PictureFrame template) {
    setState(() {
      // Add a new frame, centered on the screen initially
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      _frames.add(
        PictureFrame(
          width: template.width,
          height: template.height,
          color: template.color,
          // Start position in the center of the screen
          position: Offset(
            screenWidth / 2 - template.width / 2,
            screenHeight /
                3, // Offset slightly up from true center to avoid buttons
          ),
        ),
      );
    });
  }

  void _deleteFrame(Key key) {
    setState(() {
      _frames.removeWhere((frame) => frame.key == key);
    });
  }

  void _updateFramePosition(Key key, Offset newPosition) {
    setState(() {
      final index = _frames.indexWhere((frame) => frame.key == key);
      if (index != -1) {
        // Update the position of the specific frame
        _frames[index].position = newPosition;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(
                'Add and rearrange boxes to plan your wall.',
                style: GoogleFonts.getFont(
                  'Press Start 2P',
                  fontSize: 14,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // --- 1. The Main Drawing/Arrangement Canvas ---
          // Use a blank, light grid background image here if available
          Container(
            color: Colors.transparent,
            child: GestureDetector(
              // Allow tapping the canvas to lose focus (optional)
              onTap: () {},
              // Use a Stack to position all draggable elements
              child: Stack(
                children: _frames.map((frame) {
                  return Positioned(
                    left: frame.position.dx,
                    top: frame.position.dy,
                    child: FrameDragger(
                      key: frame.key,
                      frame: frame,
                      onDragEnd: (details) {
                        // Calculate new position based on the global coordinates of the drag
                        final newPosition = details.offset;
                        // Check if the frame was dropped onto the trash area
                        if (newPosition.dy > screenHeight - 160) {
                          _deleteFrame(frame.key);
                        } else {
                          _updateFramePosition(frame.key, newPosition);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // --- 2. The Trash Drop Area (Always on top) ---
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 75,
            child: DragTarget<Key>(
              // Accept the frame's unique Key
              onWillAccept: (data) => true,
              onAccept: _deleteFrame,
              builder: (context, candidateData, rejectedData) {
                // Determine the center position for drop check (optional, but good for custom UI)
                // Removed postFrameCallback as it's unnecessary for this check
                final isHovering = candidateData.isNotEmpty;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.green.withOpacity(0.2),
                      ),
                      child: GestureDetector(
                        onTap: widget.onGoHome,
                        child: Image.asset('assets/back.png', width: 60),
                      ),
                    ),
                    SizedBox(width: 50),
                    Container(
                      padding: EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isHovering
                            ? Colors.red.withOpacity(0.4)
                            : Colors.red.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete_forever,
                          size: 30,
                          color: isHovering
                              ? Colors.white
                              : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // --- 3. The Frame Drawer (Add Buttons) ---
          Positioned(
            bottom: 120, // Above the trash drop area
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              // color: Colors.blueGrey.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ..._frameTemplates.map((template) {
                    return FrameAddButton(
                      template: template,
                      onTap: () => _addFrame(template),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Frame Add Button Widget ---
class FrameAddButton extends StatelessWidget {
  final PictureFrame template;
  final VoidCallback onTap;

  const FrameAddButton({
    required this.template,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: template.width * 0.7,
        height: template.height * 0.7,
        decoration: BoxDecoration(
          color: template.color.withOpacity(0.8),
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: ExcludeSemantics(
            child: Text(
              'Add\n${template.width.toInt()}x${template.height.toInt()}',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                'VT323',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Draggable Frame Widget ---
class FrameDragger extends StatelessWidget {
  final PictureFrame frame;
  final Function(DraggableDetails) onDragEnd;

  const FrameDragger({required this.frame, required this.onDragEnd, super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Draggable to allow the item to be picked up
    return Draggable<Key>(
      data: frame.key, // Pass the unique Key of the frame for deletion/update
      feedback: _FrameVisual(
        frame: frame,
        opacity: 0.7,
      ), // What the user sees while dragging
      childWhenDragging:
          Container(), // Nothing visible at the original spot while dragging
      onDragEnd: onDragEnd, // Handle position update or deletion
      // The actual widget displayed on the canvas
      child: _FrameVisual(frame: frame, opacity: 1.0),
    );
  }
}

// Helper Widget for the visual representation of the frame
class _FrameVisual extends StatelessWidget {
  final PictureFrame frame;
  final double opacity;

  const _FrameVisual({required this.frame, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: frame.width,
      height: frame.height,
      decoration: BoxDecoration(
        color: frame.color.withOpacity(opacity),
        // border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: ExcludeSemantics(
          child: Text(
            '${frame.width.toInt()}x${frame.height.toInt()}',
            style: GoogleFonts.getFont(
              'VT323',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
