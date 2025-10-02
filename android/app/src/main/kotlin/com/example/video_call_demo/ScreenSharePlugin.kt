package com.example.video_call_demo

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class ScreenSharePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var mediaProjection: MediaProjection? = null
    private var screenCaptureService: ScreenCaptureService? = null
    private var serviceConnection: ServiceConnection? = null
    private var isServiceBound = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "screen_share_plugin")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d("ScreenSharePlugin", "Method called: ${call.method}")
        when (call.method) {
            "startScreenShare" -> {
                Log.d("ScreenSharePlugin", "Starting screen share...")
                startScreenCapture(result)
            }
            "stopScreenShare" -> {
                Log.d("ScreenSharePlugin", "Stopping screen share...")
                stopScreenCapture(result)
            }
            "test" -> {
                Log.d("ScreenSharePlugin", "Test method called")
                result.success("Plugin is working!")
            }
            else -> {
                Log.w("ScreenSharePlugin", "Unknown method: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun startScreenCapture(result: Result) {
        if (activity == null) {
            Log.e("ScreenSharePlugin", "No activity available")
            result.error("NO_ACTIVITY", "No activity available", null)
            return
        }

        Log.d("ScreenSharePlugin", "Starting screen capture")
        
        // Check if there's already a pending result
        if (pendingResult != null) {
            Log.w("ScreenSharePlugin", "Screen capture already in progress")
            result.error("ALREADY_IN_PROGRESS", "Screen capture already in progress", null)
            return
        }
        
        pendingResult = result
        mediaProjectionManager = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        
        try {
            // Start screen capture intent
            val intent = mediaProjectionManager?.createScreenCaptureIntent()
            if (intent != null) {
                Log.d("ScreenSharePlugin", "Launching screen capture intent")
                activity?.startActivityForResult(intent, SCREEN_CAPTURE_REQUEST_CODE)
                // DON'T call result.success() here - wait for onActivityResult
                Log.d("ScreenSharePlugin", "Screen capture intent launched, waiting for user response...")
            } else {
                Log.e("ScreenSharePlugin", "Failed to create screen capture intent")
                pendingResult = null
                result.error("SCREEN_CAPTURE_ERROR", "Failed to create screen capture intent", null)
            }
        } catch (e: Exception) {
            Log.e("ScreenSharePlugin", "Error starting screen capture: ${e.message}", e)
            pendingResult = null
            result.error("SCREEN_CAPTURE_ERROR", e.message, null)
        }
    }

    private fun stopScreenCapture(result: Result) {
        Log.d("ScreenSharePlugin", "Stopping screen capture")
        try {
            // Stop the service
            if (isServiceBound) {
                context.unbindService(serviceConnection!!)
                isServiceBound = false
            }
            
            val serviceIntent = Intent(context, ScreenCaptureService::class.java)
            context.stopService(serviceIntent)
            
            mediaProjection?.stop()
            mediaProjection = null
            screenCaptureService = null
            serviceConnection = null
            
            result.success(null)
        } catch (e: Exception) {
            Log.e("ScreenSharePlugin", "Error stopping screen capture: ${e.message}")
            result.error("STOP_SCREEN_CAPTURE_ERROR", e.message, null)
        }
    }

    private fun bindScreenCaptureService(mediaProjection: MediaProjection) {
        Log.d("ScreenSharePlugin", "Binding screen capture service")
        serviceConnection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                Log.d("ScreenSharePlugin", "Service connected")
                val binder = service as ScreenCaptureService.LocalBinder
                screenCaptureService = binder.getService()
                screenCaptureService?.setMediaProjection(mediaProjection)
                isServiceBound = true
            }

            override fun onServiceDisconnected(name: ComponentName?) {
                Log.d("ScreenSharePlugin", "Service disconnected")
                screenCaptureService = null
                isServiceBound = false
            }
        }

        val serviceIntent = Intent(context, ScreenCaptureService::class.java)
        context.bindService(serviceIntent, serviceConnection!!, Context.BIND_AUTO_CREATE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.d("ScreenSharePlugin", "Activity result: requestCode=$requestCode, resultCode=$resultCode, data=$data")
        if (requestCode == SCREEN_CAPTURE_REQUEST_CODE) {
            try {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    Log.d("ScreenSharePlugin", "Screen capture permission granted")
                    
                    // First start the foreground service
                    val serviceIntent = Intent(context, ScreenCaptureService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                    
                    // Wait a moment for service to start, then create MediaProjection
                    Thread {
                        Thread.sleep(500) // Give service time to start
                        
                        try {
                            // Now create MediaProjection after service is running
                            mediaProjection = mediaProjectionManager?.getMediaProjection(resultCode, data)
                            
                            if (mediaProjection != null) {
                                Log.d("ScreenSharePlugin", "MediaProjection created successfully")
                                
                                // Bind to service and set MediaProjection
                                bindScreenCaptureService(mediaProjection!!)
                                
                                // Success
                                activity?.runOnUiThread {
                                    pendingResult?.success(true)
                                    pendingResult = null
                                }
                            } else {
                                Log.e("ScreenSharePlugin", "Failed to create MediaProjection")
                                activity?.runOnUiThread {
                                    pendingResult?.error("MEDIA_PROJECTION_ERROR", "Failed to create MediaProjection", null)
                                    pendingResult = null
                                }
                            }
                        } catch (e: Exception) {
                            Log.e("ScreenSharePlugin", "Error creating MediaProjection: ${e.message}")
                            activity?.runOnUiThread {
                                pendingResult?.error("MEDIA_PROJECTION_ERROR", e.message, null)
                                pendingResult = null
                            }
                        }
                    }.start()
                } else {
                    Log.d("ScreenSharePlugin", "Screen capture permission denied - resultCode=$resultCode")
                    pendingResult?.error("SCREEN_CAPTURE_DENIED", "User denied screen sharing permission", null)
                    pendingResult = null
                }
            } catch (e: Exception) {
                Log.e("ScreenSharePlugin", "Error in activity result: ${e.message}", e)
                pendingResult?.error("SCREEN_CAPTURE_ERROR", e.message, null)
                pendingResult = null
            }
            return true
        }
        Log.d("ScreenSharePlugin", "Activity result for different request code: $requestCode")
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
        Log.d("ScreenSharePlugin", "Activity attached: ${activity?.javaClass?.simpleName}")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    companion object {
        private const val SCREEN_CAPTURE_REQUEST_CODE = 1001
    }
}