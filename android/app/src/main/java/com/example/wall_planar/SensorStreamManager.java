package com.example.wall_planar;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;

/** Manages sensor streams. */
public class SensorStreamManager {
    private static final String TAG = "SensorStreamManager";

    private static SensorManager sensorManager;
    private static Context applicationContext;

    /** Must be called before attempting to access sensor streams. */
    public static void initialize(Context context) {
        if (sensorManager == null) {
            applicationContext = context;
            sensorManager = (SensorManager) applicationContext.getSystemService(Context.SENSOR_SERVICE);
        }
    }

    /** Checks if a specific sensor type is available on the device. */
    public static boolean getSensorStatus(int sensorType) {
        if (sensorManager == null) {
            Log.e(TAG, "SensorManager not initialized. Cannot check sensor availability.");
            return false;
        }

        Sensor sensor = sensorManager.getDefaultSensor(sensorType);
        return (sensor != null) ? true : false;
    }

    /** Registers the provided listener for the TYPE_ROTATION_VECTOR sensor. */
    public static boolean registerRotationListener(SensorEventListener listener) {
        if (sensorManager == null) {
            Log.e(TAG, "SensorManager not initialized. Cannot register rotation listener.");
            return false;
        }

        Sensor rotationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
        if (rotationSensor == null) {
            Log.e(TAG, "Rotation Vector Sensor not found on this device.");
            return false;
        }

        // Register the listener with the fastest speed
        return sensorManager.registerListener(listener, rotationSensor, SensorManager.SENSOR_DELAY_FASTEST);
    }


    /** Registers the provided listener for the TYPE_PROXIMITY sensor. */
    public static boolean registerProximityListener(SensorEventListener listener) {
        if (sensorManager == null) {
            Log.e(TAG, "SensorManager not initialized. Cannot register proximity listener.");
            return false;
        }

        Sensor proximitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
        if (proximitySensor == null) {
            Log.e(TAG, "Proximity Sensor not found on this device.");
            return false;
        }

        // Register the listener with a standard speed
        return sensorManager.registerListener(listener, proximitySensor, SensorManager.SENSOR_DELAY_NORMAL);
    }

    /** Unregisters the provided SensorEventListener. */
    public static void unregisterSensorEventListener(SensorEventListener listener) {
        if (sensorManager != null) {
            sensorManager.unregisterListener(listener);
        }
    }
}