import 'dart:io';
import 'package:flutter_background/flutter_background.dart';
import 'logging_service.dart';

/// Service for managing background execution
class BackgroundService {
  bool _isInitialized = false;
  bool _isActive = false;

  bool get isActive => _isActive;

  /// Initialize the background service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Platform.isAndroid) {
        final androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: "LiveKit Screen Share",
          notificationText: "Screen sharing is active",
          notificationImportance: AndroidNotificationImportance.normal,
          notificationIcon: AndroidResource(
            name: 'background_icon',
            defType: 'drawable',
          ),
          enableWifiLock: true,
        );

        _isInitialized = await FlutterBackground.initialize(
          androidConfig: androidConfig,
        );

        LoggingService.info('Background service initialized: $_isInitialized');
      } else {
        // iOS and other platforms
        _isInitialized = true;
        LoggingService.info(
          'Background service initialization skipped for platform',
        );
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize background service',
        e,
        stackTrace,
      );
      _isInitialized = false;
    }
  }

  /// Start background execution
  Future<void> start() async {
    if (!_isInitialized || _isActive) return;

    try {
      if (Platform.isAndroid) {
        final hasPermissions = await FlutterBackground.hasPermissions;
        if (!hasPermissions) {
          LoggingService.warning('Background permissions not granted');
          return;
        }

        _isActive = await FlutterBackground.enableBackgroundExecution();
        LoggingService.info('Background execution enabled: $_isActive');
      } else {
        _isActive = true;
        LoggingService.info('Background execution enabled for platform');
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to start background execution',
        e,
        stackTrace,
      );
      _isActive = false;
    }
  }

  /// Stop background execution
  Future<void> stop() async {
    if (!_isActive) return;

    try {
      if (Platform.isAndroid) {
        _isActive = !await FlutterBackground.disableBackgroundExecution();
        LoggingService.info('Background execution disabled: ${!_isActive}');
      } else {
        _isActive = false;
        LoggingService.info('Background execution disabled for platform');
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to stop background execution',
        e,
        stackTrace,
      );
    }
  }

  /// Check if the service has permissions
  Future<bool> hasPermissions() async {
    if (!Platform.isAndroid || !_isInitialized) return true;

    try {
      return await FlutterBackground.hasPermissions;
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to check background permissions',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
