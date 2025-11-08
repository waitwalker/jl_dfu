package com.jl_dfu.jl_dfu

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

/**
 * JlDfuPlugin
 *
 * A Flutter plugin for Jieli OTA updates. This plugin exposes methods to start
 * and cancel firmware updates using the JL OTA SDK. Bluetooth scanning
 * and connection management must be handled by your application.
 */
class JlDfuPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var progressChannel: EventChannel
    private var progressSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "jl_dfu")
        methodChannel.setMethodCallHandler(this)
        progressChannel = EventChannel(binding.binaryMessenger, "jl_dfu_progress")
        progressChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        progressChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startOtaUpdate" -> {
                val filePath: String? = call.argument<String>("filePath")
                if (filePath.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "filePath is required", null)
                    return
                }
                // TODO: Integrate JL OTA SDK to start update using filePath.
                // Send a start status event to Flutter.
                progressSink?.success(mapOf("progress" to 0.0, "status" to "start"))
                result.success(null)
            }
            "cancelOtaUpdate" -> {
                // TODO: Cancel OTA update via JL OTA SDK.
                progressSink?.success(mapOf("progress" to 0.0, "status" to "cancelled"))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        progressSink = events
        // When integrated with the JL OTA SDK, forward progress callbacks here.
        // Example usage (to be replaced with real callback):
        // progressSink?.success(mapOf("progress" to progress, "status" to "downloading"))
    }

    override fun onCancel(arguments: Any?) {
        progressSink = null
    }
}
