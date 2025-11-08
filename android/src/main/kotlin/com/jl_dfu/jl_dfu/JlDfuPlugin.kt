package com.jl_dfu.jl_dfu

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import com.jieli.jl_bt_ota.callback.IUpgradeCallback
import com.jieli.jl_bt_ota.OTAClient
import com.jieli.jl_bt_ota.model.OTAConfigure

/**
 * JlDfuPlugin
 *
 * Implements OTA update features using the Jieli jl_bt_ota library. This plugin exposes
 * methods to start and cancel an OTA update. It assumes the application already
 * manages the Bluetooth connection and passes in a file path. Progress and status
 * events are sent back to Flutter via an EventChannel. Status strings map to
 * JL_OTAResult values defined in the iOS/Android SDKs.
 */
class JlDfuPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var progressChannel: EventChannel
    private var progressSink: EventChannel.EventSink? = null
    private var otaClient: OTAClient? = null

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
                val filePath: String? = call.argument("filePath")
                if (filePath.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "filePath is required", null)
                    return
                }
                // Build OTA configuration with file path
                val configure = OTAConfigure.Builder()
                    .setFilePath(filePath)
                    .build()
                otaClient = OTAClient.getDefault()
                otaClient?.startOTA(configure, object : IUpgradeCallback {
                    override fun onStartOTA() {
                        progressSink?.success(mapOf("progress" to 0.0, "status" to "preparing"))
                    }

                    override fun onProgress(progress: Float) {
                        // progress provided as 0-100; normalize to 0-1
                        val normalized = progress.toDouble() / 100.0
                        progressSink?.success(mapOf("progress" to normalized, "status" to "upgrading"))
                    }

                    override fun onStopOTA() {
                        progressSink?.success(mapOf("progress" to 1.0, "status" to "success"))
                    }

                    override fun onCancelOTA() {
                        progressSink?.success(mapOf("progress" to 0.0, "status" to "cancel"))
                    }

                    override fun onError(code: Int) {
                        progressSink?.success(mapOf("progress" to 0.0, "status" to "fail", "errorCode" to code))
                    }
                })
                result.success(null)
            }
            "cancelOtaUpdate" -> {
                otaClient?.cancelOTA()
                progressSink?.success(mapOf("progress" to 0.0, "status" to "cancel"))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        progressSink = events
    }

    override fun onCancel(arguments: Any?) {
        progressSink = null
    }
}
