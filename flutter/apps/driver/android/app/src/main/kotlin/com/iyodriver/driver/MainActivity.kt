package com.iyodriver.driver

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Ride offers last 15 seconds, so they use a loud heads-up channel.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(
                    "ride_offers",
                    "Ride requests",
                    NotificationManager.IMPORTANCE_HIGH,
                ),
            )
        }
    }
}
