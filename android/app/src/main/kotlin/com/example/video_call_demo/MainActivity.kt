package com.example.video_call_demo

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Log
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.PluginRegistry

class MainActivity: FlutterActivity() {
    private var isInPictureInPictureMode = false
    private var isScreenSharing = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            flutterEngine.plugins.add(ScreenSharePlugin())
            flutterEngine.plugins.add(PictureInPicturePlugin())
        } catch (e: Exception) {
            Log.e("MainActivity", "Error registering plugins: ${e.message}")
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        Log.d("MainActivity", "User leaving app, isScreenSharing: $isScreenSharing")
        
        // Enter PiP mode when screen sharing and user leaves the app
        if (isScreenSharing && !isInPictureInPictureMode) {
            enterPiPMode()
        }
    }

    private fun enterPiPMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val pipParams = PictureInPictureParams.Builder()
                    .setAspectRatio(Rational(16, 9)) // 16:9 aspect ratio
                    .build()
                
                val result = enterPictureInPictureMode(pipParams)
                Log.d("MainActivity", "PiP mode result: $result")
                isInPictureInPictureMode = result
            } catch (e: Exception) {
                Log.e("MainActivity", "Error entering PiP mode: ${e.message}")
            }
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        this.isInPictureInPictureMode = isInPictureInPictureMode
        Log.d("MainActivity", "PiP mode changed: $isInPictureInPictureMode")
        
        if (isInPictureInPictureMode) {
            // App is now in PiP mode
            Log.d("MainActivity", "App entered PiP mode")
        } else {
            // App returned from PiP mode
            Log.d("MainActivity", "App exited PiP mode")
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        Log.d("MainActivity", "Configuration changed")
    }

    // Method to be called from Flutter to indicate screen sharing state
    fun setScreenSharingState(sharing: Boolean) {
        isScreenSharing = sharing
        Log.d("MainActivity", "Screen sharing state set to: $sharing")
    }

    // Method to be called from Flutter to enter PiP mode
    fun enterPiPModeFromFlutter() {
        enterPiPMode()
    }

    override fun onDestroy() {
        Log.d("MainActivity", "MainActivity destroyed")
        super.onDestroy()
    }
}