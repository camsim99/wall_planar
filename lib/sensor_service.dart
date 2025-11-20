import 'dart:math';

import 'package:flutter/services.dart';
import 'package:jni/jni.dart';

import 'measure_utils.g.dart';

class SensorService {
  late final EventChannel _rotationChannel;
  late final EventChannel _proximityChannel;
  late final EventChannel _distanceAccumulationChannel;
  final double _radiansToDegrees = 180.0 / pi;

  SensorService() {
    // Ensure native SensorManager is initialized.
    MeasureUtils.initialize(Jni.androidApplicationContext);

    // Setup the EventChannel using the name retrieved from the native layer
    final String rotationChannelName = MeasureUtils.getRotationChannelName()
        .toString();
    final String proximityChannelName = MeasureUtils.getProximityChannelName()
        .toString();
    final String distanceAccumulationChannelName =
        MeasureUtils.getAccelerometerUnitsStreamChannelName().toString();

    _rotationChannel = EventChannel(rotationChannelName);
    _proximityChannel = EventChannel(proximityChannelName);
    _distanceAccumulationChannel = EventChannel(
      distanceAccumulationChannelName,
    );
  }

  /// Streams accumulated distance units (Wall Units) from the native Accelerometer.
  Stream<double> get distanceAccumulationStream {
    // Ensure rotation sensor is supported.
    bool distanceAccumulationSensorIsSupported = MeasureUtils.isSensorAvailable(
      1 /* TYPE_ACCELEROMETER */,
    );

    if (!distanceAccumulationSensorIsSupported) {
      throw UnsupportedError("This entire app is pointless :(");
    }

    // We assume the native side integrates the X-axis acceleration and sends the total accumulated unit value.
    return _distanceAccumulationChannel
        .receiveBroadcastStream()
        .cast<List<dynamic>>()
        .map((data) {
          return (data.isNotEmpty ? data.first : 0.0) as double;
        });
  }

  /// Streams raw proximity distance (cm) from the native sensor.
  Stream<double> get proximityStream {
    // Ensure rotation sensor is supported.
    bool proximitySensorIsSupported = MeasureUtils.isSensorAvailable(
      8 /* TYPE_PROXIMITY */,
    );

    if (!proximitySensorIsSupported) {
      throw UnsupportedError("This entire app is pointless :(");
    }

    // The native Java side sends a List<Float> with one element; we map it to a single double.
    return _proximityChannel.receiveBroadcastStream().cast<List<dynamic>>().map(
      (data) {
        return (data.isNotEmpty ? data.first : 0.0) as double;
      },
    );
  }

  /// Streams raw 4-component Quaternion data from the native Rotation Vector sensor.
  /// Output: [x, y, z, w]
  Stream<List<double>> get rotationQuaternionStream {
    // Ensure rotation sensor is supported.
    bool rotationSensorIsSupported = MeasureUtils.isSensorAvailable(
      11 /* TYPE_ROTATION_VECTOR */,
    );

    if (!rotationSensorIsSupported) {
      throw UnsupportedError("This entire app is pointless :(");
    }

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
