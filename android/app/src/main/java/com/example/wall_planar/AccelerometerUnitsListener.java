package com.example.wall_planar;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import io.flutter.plugin.common.EventChannel;
import android.util.Log;

import java.util.Collections;
import java.util.List;

/** Manages the TYPE_ACCELEROMETER data stream, used for the slide measure mode. */
public class AccelerometerUnitsListener implements EventChannel.StreamHandler, SensorEventListener {
    // Define the Channel Name for registration in MainActivity (Matches Dart service layer)
    public static final String ACCELEROMETER_UNITS_CHANNEL = "com.wallplanar/accelerometer_stream";
    
    private EventChannel.EventSink accelerationSink;
    

    private float totalAccumulatedDistance = 0.0f; // The running sum (Wall Units)
    private long lastTimeNs = 0; // Timestamp of the previous sensor event (in nanoseconds)

    // Simplified filter constant to reduce noise
    private static final float NS2S = 1.0f / 1000000000.0f; // Nanoseconds to Seconds
    private static final float SENSITIVITY_THRESHOLD = 0.5f; // Ignore motion below this threshold (m/s^2)

    public AccelerometerUnitsListener(Context context) {
        // Ensure the central SensorManager is initialized before attempting registration
        SensorStreamManager.initialize(context); 
    }
    
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.accelerationSink = events;
        
        // Reset accumulation state when listening starts
        totalAccumulatedDistance = 0.0f;
        lastTimeNs = 0;

        // Delegate registration to the centralized SensorStreamManager
        boolean success = SensorStreamManager.registerAccelerometerListener(this);
        
        if (!success) {
            events.error("UNAVAILABLE", "Accelerometer Sensor not found or manager failed to register.", null);
        }
    }

    @Override
    public void onCancel(Object arguments) {
        SensorStreamManager.unregisterSensorEventListener(this);
        this.accelerationSink = null;
    }
    
    @Override
    public void onSensorChanged(SensorEvent event) {
        if (accelerationSink != null) {
            
            // Perform accumulation only if we have a previous timestamp
            if (lastTimeNs != 0) {
                // Time difference in seconds
                final float dT = (event.timestamp - lastTimeNs) * NS2S;
                
                // --- Integration/Accumulation Logic ---
                
                // 1. Get the primary measurement axis (X-axis for side-to-side sliding)
                float accelerationX = event.values[0]; 
                
                // 2. Filter out small noise
                if (Math.abs(accelerationX) > SENSITIVITY_THRESHOLD) {
                    
                    // *** FIX A: Accumulate the ABSOLUTE VALUE of acceleration * dT ***
                    // This prevents negative drift and ensures we measure total motion.
                    totalAccumulatedDistance += Math.abs(accelerationX * dT); 
                    
                    // We must update the timestamp *after* use
                    lastTimeNs = event.timestamp;
                } else {
                    // Only update timestamp if motion is significant, to avoid skipping large gaps.
                    lastTimeNs = event.timestamp;
                }

                // Push the running accumulated total to Dart (Wall Units)
                List<Float> accumulatedUnit = Collections.singletonList(totalAccumulatedDistance);
                accelerationSink.success(accumulatedUnit);
            } else {
                // Initialize timestamp on first run
                lastTimeNs = event.timestamp;
            }
        }
        
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        // Required, but we don't care :)
    }
}