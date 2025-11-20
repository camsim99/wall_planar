package com.example.wall_planar;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Register the event channels for receiving sensor stream events.
        new EventChannel(
            flutterEngine.getDartExecutor().getBinaryMessenger(), 
            RotationSensorListener.ROTATION_CHANNEL
        ).setStreamHandler(new RotationSensorListener(getApplicationContext()));
        new EventChannel(
            flutterEngine.getDartExecutor().getBinaryMessenger(), 
            ProximitySensorListener.PROXIMITY_CHANNEL
        ).setStreamHandler(new ProximitySensorListener(getApplicationContext()));
        new EventChannel(
            flutterEngine.getDartExecutor().getBinaryMessenger(), 
            AccelerometerUnitsListener.ACCELEROMETER_UNITS_CHANNEL
        ).setStreamHandler(new AccelerometerUnitsListener(getApplicationContext()));
    }
}
