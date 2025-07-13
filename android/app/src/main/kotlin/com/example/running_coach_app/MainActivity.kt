package com.example.running_coach_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "running_coach_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    val intent = Intent(this, RunningService::class.java).apply {
                        action = "START_FOREGROUND"
                    }
                    startService(intent)
                    result.success(null)
                }
                "stopForegroundService" -> {
                    val intent = Intent(this, RunningService::class.java).apply {
                        action = "STOP_FOREGROUND"
                    }
                    startService(intent)
                    result.success(null)
                }
                "isServiceRunning" -> {
                    // For simplicity, we'll return true if the service was started
                    // In a real app, you'd want to track the service state more carefully
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
} 