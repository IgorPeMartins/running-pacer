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
            "PAUSE_RUNNING" -> pauseRunning()
            "RESUME_RUNNING" -> resumeRunning()
            "STOP_RUNNING" -> stopRunning()
        }
        return START_STICKY
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            channelId,
            "Running Coach",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Running Coach Background Service"
            setSound(null, null)
            enableLights(true)
            enableVibration(true)
            setShowBadge(true)
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

        // Create pause/resume action
        val pauseResumeIntent = Intent(this, RunningService::class.java).apply {
            action = if (isRunning) "PAUSE_RUNNING" else "RESUME_RUNNING"
        }
        val pauseResumePendingIntent = PendingIntent.getService(
            this, 1, pauseResumeIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        // Create stop action
        val stopIntent = Intent(this, RunningService::class.java).apply {
            action = "STOP_RUNNING"
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 2, stopIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Running Coach Active")
            .setContentText("Voice coaching and cadence running")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .addAction(
                android.R.drawable.ic_media_pause,
                if (isRunning) "Pause" else "Resume",
                pauseResumePendingIntent
            )
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Stop",
                stopPendingIntent
            )
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
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

    private fun pauseRunning() {
        isRunning = false
        updateNotification()
        // Send message to Flutter to pause
        sendBroadcast(Intent("RUNNING_PAUSED"))
        Log.d("RunningService", "Running paused")
    }

    private fun resumeRunning() {
        isRunning = true
        updateNotification()
        // Send message to Flutter to resume
        sendBroadcast(Intent("RUNNING_RESUMED"))
        Log.d("RunningService", "Running resumed")
    }

    private fun stopRunning() {
        isRunning = false
        updateNotification()
        // Send message to Flutter to stop
        sendBroadcast(Intent("RUNNING_STOPPED"))
        stopForeground()
        Log.d("RunningService", "Running stopped")
    }

    private fun updateNotification() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        // Create pause/resume action
        val pauseResumeIntent = Intent(this, RunningService::class.java).apply {
            action = if (isRunning) "PAUSE_RUNNING" else "RESUME_RUNNING"
        }
        val pauseResumePendingIntent = PendingIntent.getService(
            this, 1, pauseResumeIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        // Create stop action
        val stopIntent = Intent(this, RunningService::class.java).apply {
            action = "STOP_RUNNING"
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 2, stopIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Running Coach Active")
            .setContentText(if (isRunning) "Voice coaching and cadence running" else "Paused")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .addAction(
                android.R.drawable.ic_media_pause,
                if (isRunning) "Pause" else "Resume",
                pauseResumePendingIntent
            )
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Stop",
                stopPendingIntent
            )
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(notificationId, notification)
    }

    fun isServiceRunning(): Boolean = isRunning
} 