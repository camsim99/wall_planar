import 'dart:math';

import 'package:flutter/services.dart';
import 'package:jni/jni.dart';

import 'measure_utils.g.dart';

class RotationSensorService {
  late final EventChannel _rotationChannel;
  final double _radiansToDegrees = 180.0 / pi;

  RotationSensorService() {
    // Ensure native SensorManager is initialized.
    MeasureUtils.initialize(Jni.androidApplicationContext);

    // Setup the EventChannel using the name retrieved from the native layer
    final String channelName = MeasureUtils.getRotationChannelName().toString();
    _rotationChannel = EventChannel(channelName);
  }

  /// Streams raw 4-component Quaternion data from the native Rotation Vector sensor.
  /// Output: [x, y, z, w]
  Stream<List<double>> get rotationQuaternionStream {
    return _rotationChannel.receiveBroadcastStream().cast<List<dynamic>>().map((
      data,
    ) {
      return data.cast<double>();
    });
  }

  /// Streams the processed Euler angles (Pitch, Roll, Yaw) in degrees.
  Stream<Map<String, double>> get eulerAngleStream {
    return rotationQuaternionStream.map(_convertQuaternionToEuler);
  }

  /// Converts the 4-component Quaternion [x, y, z, w] into 3 Euler angles (Pitch, Roll, Yaw) in degrees.
  Map<String, double> _convertQuaternionToEuler(List<double> q) {
    if (q.length < 4) return {'pitch': 0.0, 'roll': 0.0, 'yaw': 0.0};

    final double x = q[0], y = q[1], z = q[2], w = q[3];

    // Standard Quaternion to Euler formulas (in radians)
    // Roll (rotation around X-axis): bank angle
    double rollRad = atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y));

    // Pitch (rotation around Y-axis): elevation
    double pitchRad = asin(2 * (w * y - z * x));

    // Yaw (rotation around Z-axis): heading
    double yawRad = atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z));

    // Convert to degrees and map to 0-360 range if needed, or keep -180 to 180.
    return {
      'roll': (rollRad * _radiansToDegrees),
      'pitch': (pitchRad * _radiansToDegrees),
      'yaw': (yawRad * _radiansToDegrees),
    };
  }
}
