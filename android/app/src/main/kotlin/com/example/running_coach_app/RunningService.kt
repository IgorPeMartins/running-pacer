package com.example.running_coach_app

import android.app.*
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import java.util.*

class RunningService : Service() {
    private val binder = RunningBinder()
    private var isRunning = false
    private var notificationId = 1
    private val channelId = "running_coach_channel"

    inner class RunningBinder : Binder() {
        fun getService(): RunningService = this@RunningService
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START_FOREGROUND" -> startForeground()
            "STOP_FOREGROUND" -> stopForeground()
        }
        return START_STICKY
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            channelId,
            "Running Coach",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "Running Coach Background Service"
            setSound(null, null)
            enableLights(true)
            enableVibration(true)
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)
    }

    private fun startForeground() {
        isRunning = true
        
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Running Coach Active")
            .setContentText("Voice coaching and metronome running")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()

        startForeground(notificationId, notification)
        Log.d("RunningService", "Foreground service started")
    }

    private fun stopForeground() {
        isRunning = false
        stopForeground(true)
        stopSelf()
        Log.d("RunningService", "Foreground service stopped")
    }

    fun isServiceRunning(): Boolean = isRunning
} 