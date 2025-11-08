import Flutter
import UIKit
import JL_OTALib

public class JlDfuPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jl_dfu", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "jl_dfu_progress", binaryMessenger: registrar.messenger())
        let instance = JlDfuPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startOtaUpdate":
            if let args = call.arguments as? [String: Any],
               let filePath = args["filePath"] as? String {
                // TODO: Integrate JL_OTALib to start OTA update with filePath.
                // Send start status event.
                eventSink?(["progress": 0.0, "status": "start"])
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "filePath is required", details: nil))
            }
        case "cancelOtaUpdate":
            // TODO: Cancel OTA update using JL_OTALib.
            eventSink?(["progress": 0.0, "status": "cancelled"])
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        // When integrated with JL_OTALib, forward progress callbacks using:
        // eventSink(["progress": progressValue, "status": "downloading"])
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
