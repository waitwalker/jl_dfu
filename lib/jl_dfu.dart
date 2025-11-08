library jl_dfu;

import 'dart:async';
import 'package:flutter/services.dart';

/// A Flutter wrapper for the Jieli OTA (DFU) SDKs.
///
/// This plugin exposes methods to start and cancel firmware updates on
/// Bluetooth devices that use Jieli chipsets. Only the OTA protocol
/// is implemented here; your application is responsible for scanning
/// for devices, establishing a BLE connection and ensuring the device
/// remains connected during the update.
class JlDfu {
  // Method channel used to send commands to the native platforms.
  static const MethodChannel _methodChannel = MethodChannel('jl_dfu');

  // Event channel used to receive progress updates from the native platforms.
  static const EventChannel _progressChannel = EventChannel('jl_dfu_progress');

  /// Starts the OTA firmware update on the connected device.
  ///
  /// [filePath] must be an absolute path on the device file system
  /// pointing to the firmware binary to be transferred. This method
  /// returns immediately; listen to [otaProgressStream] for progress
  /// notifications. If the native implementation encounters an error,
  /// it will throw a platform-specific exception.
  static Future<void> startOtaUpdate(String filePath) async {
    assert(filePath.isNotEmpty, 'filePath cannot be empty');
    await _methodChannel.invokeMethod('startOtaUpdate', {
      'filePath': filePath,
    });
  }

  /// Cancels an ongoing OTA update. If no update is in progress, this
  /// call has no effect.
  static Future<void> cancelOtaUpdate() async {
    await _methodChannel.invokeMethod('cancelOtaUpdate');
  }

  /// Provides a stream of OTA update progress values from 0.0 to 100.0.
  ///
  /// Native platforms should emit numeric progress updates as percentages.
  static Stream<double> get otaProgressStream {
    return _progressChannel
        .receiveBroadcastStream()
        .map((dynamic event) => (event as num).toDouble());
  }
}
