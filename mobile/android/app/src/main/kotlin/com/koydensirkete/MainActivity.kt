package com.koydensirkete

import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.koydensirkete/feedback",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playClick" -> {
                    playClick()
                    result.success(null)
                }
                "vibrate" -> {
                    vibrate()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playClick() {
        val tone = ToneGenerator(AudioManager.STREAM_MUSIC, 70)
        tone.startTone(ToneGenerator.TONE_PROP_ACK, 90)
        Handler(Looper.getMainLooper()).postDelayed({ tone.release() }, 120)
    }

    @Suppress("DEPRECATION")
    private fun vibrate() {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(VibratorManager::class.java).defaultVibrator
        } else {
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        if (!vibrator.hasVibrator()) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(
                VibrationEffect.createOneShot(
                    45,
                    VibrationEffect.DEFAULT_AMPLITUDE,
                ),
            )
        } else {
            vibrator.vibrate(45)
        }
    }
}
