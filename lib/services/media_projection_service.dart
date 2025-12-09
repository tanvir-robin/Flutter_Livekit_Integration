import 'dart:io';
import 'package:flutter/services.dart';
import 'logging_service.dart';

/// Service for managing platform-specific media projection services
class MediaProjectionService {
  static const _channel = MethodChannel(
    'com.example.livekit_demo/media_projection',
  );

  /// Start the native media projection service (Android only)
  static Future<bool> startService() async {
    if (!Platform.isAndroid) {
      LoggingService.debug(
        'MediaProjection service not needed on this platform',
      );
      return true;
    }

    try {
      final result = await _channel.invokeMethod('startMediaProjectionService');
      LoggingService.info('Media projection service started: $result');
      return result == true;
    } catch (e) {
      LoggingService.error('Failed to start media projection service', e);
      return false;
    }
  }

  /// Stop the native media projection service (Android only)
  static Future<bool> stopService() async {
    if (!Platform.isAndroid) {
      LoggingService.debug(
        'MediaProjection service not needed on this platform',
      );
      return true;
    }

    try {
      final result = await _channel.invokeMethod('stopMediaProjectionService');
      LoggingService.info('Media projection service stopped: $result');
      return result == true;
    } catch (e) {
      LoggingService.error('Failed to stop media projection service', e);
      return false;
    }
  }
}
