import 'dart:io';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';
import 'logging_service.dart';
import 'background_service.dart';
import 'media_projection_service.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  lk.Room? _room;
  lk.LocalVideoTrack? _screenShareTrack;
  final _backgroundService = BackgroundService();

  lk.Room? get room => _room;
  lk.LocalVideoTrack? get screenShareTrack => _screenShareTrack;
  bool get isConnected =>
      _room?.connectionState == lk.ConnectionState.connected;
  bool get isScreenSharing => _screenShareTrack != null;

  Future<void> initialize() async {
    LoggingService.info('Initializing LiveKit service');
    await _backgroundService.initialize();
  }

  Future<void> connect({
    required String url,
    required String token,
    required String participantName,
  }) async {
    try {
      LoggingService.info('Connecting to LiveKit room: $url');

      _room = lk.Room();
      _room!.addListener(_onRoomUpdate);
      await _room!.connect(
        url,
        token,
        roomOptions: const lk.RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultCameraCaptureOptions: lk.CameraCaptureOptions(
            maxFrameRate: 30,
          ),
        ),
        fastConnectOptions: lk.FastConnectOptions(
          microphone: lk.TrackOption(enabled: false),
          camera: lk.TrackOption(enabled: false),
        ),
      );

      LoggingService.info('Successfully connected to LiveKit room');
    } catch (e, stackTrace) {
      LoggingService.error('Failed to connect to LiveKit room', e, stackTrace);
      await disconnect();
      rethrow;
    }
  }

  /// Disconnect from the LiveKit room
  Future<void> disconnect() async {
    try {
      LoggingService.info('Disconnecting from LiveKit room');

      // Stop screen sharing if active
      await stopScreenShare();

      // Remove listeners and disconnect
      _room?.removeListener(_onRoomUpdate);
      await _room?.disconnect();
      _room?.dispose();
      _room = null;

      // Stop background service
      await _backgroundService.stop();

      LoggingService.info('Successfully disconnected from LiveKit room');
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error disconnecting from LiveKit room',
        e,
        stackTrace,
      );
    }
  }

  /// Start screen sharing
  Future<void> startScreenShare() async {
    try {
      LoggingService.info('Starting screen share');

      if (_room == null || !isConnected) {
        throw Exception('Not connected to a room');
      }

      if (isScreenSharing) {
        LoggingService.warning('Screen sharing already active');
        return;
      }

      // Request permissions
      await _requestPermissions();

      // Start media projection service FIRST (required on Android 14+)
      if (Platform.isAndroid) {
        final serviceStarted = await MediaProjectionService.startService();
        if (!serviceStarted) {
          throw Exception('Failed to start media projection service');
        }
        LoggingService.info('Media projection service started successfully');
      }

      // Start background service AFTER media projection service
      await _backgroundService.start();
      LoggingService.info('Background service started for media projection');

      // Create screen share track
      await _createScreenShareTrack();

      // Publish the track
      if (_screenShareTrack != null) {
        await _room!.localParticipant?.publishVideoTrack(_screenShareTrack!);
        LoggingService.info('Screen share track published successfully');
      }
    } catch (e, stackTrace) {
      LoggingService.error('Failed to start screen share', e, stackTrace);
      await stopScreenShare();
      rethrow;
    }
  }

  /// Stop screen sharing
  Future<void> stopScreenShare() async {
    try {
      LoggingService.info('Stopping screen share');

      if (_screenShareTrack != null) {
        // Unpublish the track - simplified approach
        final localParticipant = _room?.localParticipant;
        if (localParticipant != null) {
          // The track will be automatically unpublished when we stop it
          LoggingService.info('Unpublishing screen share track');
        }

        // Stop and dispose the track
        await _screenShareTrack!.stop();
        await _screenShareTrack!.dispose();
        _screenShareTrack = null;
      }

      // Stop background service
      await _backgroundService.stop();

      // Stop media projection service on Android
      if (Platform.isAndroid) {
        await MediaProjectionService.stopService();
        LoggingService.info('Media projection service stopped');
      }

      LoggingService.info('Screen share stopped successfully');
    } catch (e, stackTrace) {
      LoggingService.error('Error stopping screen share', e, stackTrace);
    }
  }

  /// Request necessary permissions for screen sharing
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request microphone permission for system audio (optional)
      final micPermission = await Permission.microphone.request();
      LoggingService.info('Microphone permission status: $micPermission');

      // Request notification permission for background service
      final notificationPermission = await Permission.notification.request();
      LoggingService.info(
        'Notification permission status: $notificationPermission',
      );

      // Request system alert window permission
      final systemAlertPermission = await Permission.systemAlertWindow
          .request();
      LoggingService.info(
        'System alert window permission status: $systemAlertPermission',
      );
    } else if (Platform.isIOS) {
      // iOS permissions are handled by the system during screen recording
      LoggingService.info('iOS permissions will be requested by system');
    }
  }

  /// Create screen share track based on platform
  Future<void> _createScreenShareTrack() async {
    if (Platform.isIOS) {
      // iOS screen sharing with ReplayKit
      _screenShareTrack = await lk.LocalVideoTrack.createScreenShareTrack(
        const lk.ScreenShareCaptureOptions(
          useiOSBroadcastExtension: true,
          maxFrameRate: 30,
        ),
      );
    } else if (Platform.isAndroid) {
      // Android screen sharing with MediaProjection
      // The permission request is handled internally by createScreenShareTrack
      _screenShareTrack = await lk.LocalVideoTrack.createScreenShareTrack(
        const lk.ScreenShareCaptureOptions(
          captureScreenAudio: true,
          maxFrameRate: 30,
        ),
      );
    } else {
      // Desktop screen sharing
      _screenShareTrack = await lk.LocalVideoTrack.createScreenShareTrack(
        const lk.ScreenShareCaptureOptions(
          captureScreenAudio: true,
          maxFrameRate: 30,
        ),
      );
    }
  }

  /// Handle room updates
  void _onRoomUpdate() {
    LoggingService.debug('Room state updated: ${_room?.connectionState}');
  }

  /// Dispose the service
  Future<void> dispose() async {
    await disconnect();
    LoggingService.info('LiveKit service disposed');
  }
}
