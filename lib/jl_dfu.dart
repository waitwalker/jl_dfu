library jl_dfu;

import 'dart:async';
import 'package:flutter/services.dart';

/// A wrapper around the Jieli OTA SDK that exposes firmware update functions.
///
/// This plugin exposes methods to start and cancel firmware upgrades on devices
/// that use Jieli chipsets. Scanning and connection management must be
/// implemented by the host application; only OTA file transfer is handled here.
class JlDfu {
  static const MethodChannel _methodChannel = MethodChannel('jl_dfu');
  static const EventChannel _progressChannel = EventChannel('jl_dfu_progress');

  /// Starts the OTA firmware update on the connected device.
  ///
  /// [filePath] must be an absolute path to the firmware file to upgrade to.
  /// Ensure the device is connected via BLE before calling this method.
  static Future<void> startOtaUpdate(String filePath) async {
    await _methodChannel.invokeMethod('startOtaUpdate', {'filePath': filePath});
  }

  /// Cancels the ongoing OTA update if supported.
  static Future<void> cancelOtaUpdate() async {
    await _methodChannel.invokeMethod('cancelOtaUpdate');
  }

  /// Provides a stream of OTA progress updates.
  ///
  /// The stream emits [JlOtaResult] objects that contain the progress value
  /// (0–100) and a status string describing the current OTA stage (e.g.
  /// `start`, `downloading`, `upgrading`, `success`, `cancelled`, `error`).
  /// Native platforms should send a map with keys `progress`, `status`
  /// and optionally `errorCode` to describe errors.
  static Stream<JlOtaResult> get otaProgressStream {
    return _progressChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        return JlOtaResult.fromMap(event);
      }
      if (event is num) {
        return JlOtaResult(progress: event.toDouble(), status: 'progress');
      }
      return JlOtaResult(progress: 0.0, status: 'unknown');
    });
  }
}

/// A wrapper containing OTA progress and status.
///
/// [progress] is a floating-point number between 0 and 100 indicating the
/// percentage of the OTA operation that has completed.
/// [status] is a string representing the stage or result of the OTA process.
/// The native code should set this based on the JL_OTAResult from the SDK.
/// [errorCode] may contain an error code if the update failed.
class JlOtaResult {
  final double progress;
  final String status;
  final int? errorCode;

  JlOtaResult({
    required this.progress,
    required this.status,
    this.errorCode,
  });

  factory JlOtaResult.fromMap(Map<dynamic, dynamic> map) {
    final progressValue = map['progress'];
    double progress = 0.0;
    if (progressValue is num) {
      progress = progressValue.toDouble();
    }
    final status = map['status']?.toString() ?? '';
    final errorCode = map['errorCode'] is int ? map['errorCode'] as int : null;
    return JlOtaResult(
      progress: progress,
      status: status,
      errorCode: errorCode,
    );
  }
}
