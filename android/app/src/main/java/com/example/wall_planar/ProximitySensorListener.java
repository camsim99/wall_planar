package com.example.wall_planar;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import io.flutter.plugin.common.EventChannel;

import java.util.Collections;
import java.util.List;

/** Manages the TYPE_PROXIMITY data stream. */
public class ProximitySensorListener implements EventChannel.StreamHandler, SensorEventListener {
    // Define the Channel Name for registration in MainActivity
    public static final String PROXIMITY_CHANNEL = "com.wallplanar/proximity_stream";

    private static final String TAG = "ProximitySensorListener";
    
    private EventChannel.EventSink proximitySink;

    public ProximitySensorListener(Context context) {
        // Ensure the central SensorManager is initialized before attempting registration
        SensorStreamManager.initialize(context); 
    }
    
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.proximitySink = events;
        
        boolean success = SensorStreamManager.registerProximityListener(this);
        
        if (!success) {
            events.error("UNAVAILABLE", "Proximity Sensor not found or manager failed to register.", null);
        }
    }

    @Override
    public void onCancel(Object arguments) {
        SensorStreamManager.unregisterSensorEventListener(this);
        this.proximitySink = null;
    }
    
    @Override
    public void onSensorChanged(SensorEvent event) {
        if (proximitySink != null && event.sensor.getType() == Sensor.TYPE_PROXIMITY) {
            // The TYPE_PROXIMITY provides a single float value (distance in cm).
            // We pass it as a List<Float> to maintain consistency with the EventChannel data types.
            List<Float> distance = Collections.singletonList(event.values[0]);
            
            // Push the data to the Dart stream
            proximitySink.success(distance);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        // Required, but we don't care :)
    }
}