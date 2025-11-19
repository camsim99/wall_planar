package com.example.wall_planar;

import android.content.Context;
import androidx.annotation.Keep;

@Keep
public abstract class MeasureUtils { 
    private MeasureUtils() {} // Hide constructor

    public static void initialize(Context context) {
        SensorStreamManager.initialize(context);
    }

    public static boolean isSensorAvailable(int sensorType) {
        return SensorStreamManager.getSensorStatus(sensorType);
    }

    public static String getRotationChannelName() {
        return RotationSensorListener.ROTATION_CHANNEL;
    }

    public static String getProximityChannelName() {
        return ProximitySensorListener.PROXIMITY_CHANNEL;
    }
}