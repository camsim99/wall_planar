package com.example.wall_planar;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import io.flutter.plugin.common.EventChannel;

import java.util.Arrays;
import java.util.List;

/** Manages the TYPE_ROTATION_VECTOR sensor stream. */
public class RotationSensorListener implements EventChannel.StreamHandler, SensorEventListener {
    // Define the Channel Name for registration in MainActivity
    public static final String ROTATION_CHANNEL = "com.wallplanar/rotation_stream";

    private static final String TAG = "RotationSensorListener";
    
    private EventChannel.EventSink rotationSink;

    public RotationSensorListener(Context context) {
        SensorStreamManager.initialize(context); 
    }
    

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.rotationSink = events;

        boolean success = SensorStreamManager.registerRotationListener(this);
        
        if (!success) {
            events.error("UNAVAILABLE", "Rotation Vector Sensor not found or manager failed to register.", null);
        }
    }

    @Override
    public void onCancel(Object arguments) {
        SensorStreamManager.unregisterSensorEventListener(this);
        this.rotationSink = null;
    }
    
    @Override
    public void onSensorChanged(SensorEvent event) {
        if (rotationSink != null && event.sensor.getType() == Sensor.TYPE_ROTATION_VECTOR) {
            // The TYPE_ROTATION_VECTOR provides 4 floats (x, y, z, w) as a Quaternion.
            // This list is automatically serialized and sent over the EventChannel to Dart.
            List<Float> quaternion = Arrays.asList(
                event.values[0], // x component
                event.values[1], // y component
                event.values[2], // z component
                event.values[3]  // w component
            );
            
            // Push the data to the Dart stream
            rotationSink.success(quaternion);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        // Required, but we don't care :)
    }
}