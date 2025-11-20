import 'package:flutter/material.dart';

import 'level_view.dart';

void main() {
  runApp(const WallPlanarApp());
}

class WallPlanarApp extends StatelessWidget {
  const WallPlanarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WallPlanar Level View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // brightness: Brightness.light, // Dark mode aesthetic
        primarySwatch: Colors.blue,
        // fontFamily: 'Inter',
      ),
      home: LevelView(),
    );
  }
}
