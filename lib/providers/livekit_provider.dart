import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../models/app_state.dart';
import '../services/livekit_service.dart';
import '../services/logging_service.dart';

final liveKitProvider = StateNotifierProvider<LiveKitNotifier, AppState>((ref) {
  return LiveKitNotifier();
});

class LiveKitNotifier extends StateNotifier<AppState> {
  LiveKitNotifier() : super(const AppState()) {
    _initialize();
  }

  final _liveKitService = LiveKitService();

  Future<void> _initialize() async {
    try {
      await _liveKitService.initialize();
      LoggingService.info('LiveKit provider initialized');
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize LiveKit provider',
        e,
        stackTrace,
      );
      state = state.copyWith(
        connectionState: AppConnectionState.error,
        errorMessage: 'Failed to initialize: ${e.toString()}',
      );
    }
  }

  Future<void> connect({
    required String url,
    required String token,
    required String participantName,
  }) async {
    if (state.isConnected) {
      LoggingService.warning('Already connected to a room');
      return;
    }

    state = state.copyWith(
      connectionState: AppConnectionState.connecting,
      participantName: participantName,
      clearError: true,
    );

    try {
      await _liveKitService.connect(
        url: url,
        token: token,
        participantName: participantName,
      );

      // Extract room name from the connection
      final roomName = _liveKitService.room?.name ?? 'Unknown Room';

      state = state.copyWith(
        connectionState: AppConnectionState.connected,
        roomName: roomName,
      );

      LoggingService.info('Connected to room: $roomName');
    } catch (e, stackTrace) {
      LoggingService.error('Failed to connect to room', e, stackTrace);
      state = state.copyWith(
        connectionState: AppConnectionState.error,
        errorMessage: 'Connection failed: ${e.toString()}',
      );
    }
  }

  /// Disconnect from the LiveKit room
  Future<void> disconnect() async {
    try {
      await _liveKitService.disconnect();
      state = const AppState(); // Reset to initial state
      LoggingService.info('Disconnected from room');
    } catch (e, stackTrace) {
      LoggingService.error('Failed to disconnect from room', e, stackTrace);
      state = state.copyWith(
        errorMessage: 'Disconnect failed: ${e.toString()}',
      );
    }
  }

  /// Start screen sharing
  Future<void> startScreenShare() async {
    if (!state.isConnected) {
      state = state.copyWith(
        errorMessage: 'Must be connected to start screen sharing',
      );
      return;
    }

    if (state.isScreenSharing) {
      LoggingService.warning('Screen sharing already active');
      return;
    }

    state = state.copyWith(
      screenShareState: ScreenShareState.starting,
      clearError: true,
    );

    try {
      await _liveKitService.startScreenShare();
      state = state.copyWith(
        screenShareState: ScreenShareState.active,
        isBackgroundEnabled: true,
      );
      LoggingService.info('Screen sharing started');
    } catch (e, stackTrace) {
      LoggingService.error('Failed to start screen sharing', e, stackTrace);
      state = state.copyWith(
        screenShareState: ScreenShareState.error,
        errorMessage: 'Screen share failed: ${e.toString()}',
      );
    }
  }

  /// Stop screen sharing
  Future<void> stopScreenShare() async {
    if (!state.isScreenSharing) {
      LoggingService.warning('Screen sharing not active');
      return;
    }

    state = state.copyWith(
      screenShareState: ScreenShareState.stopping,
      clearError: true,
    );

    try {
      await _liveKitService.stopScreenShare();
      state = state.copyWith(
        screenShareState: ScreenShareState.idle,
        isBackgroundEnabled: false,
      );
      LoggingService.info('Screen sharing stopped');
    } catch (e, stackTrace) {
      LoggingService.error('Failed to stop screen sharing', e, stackTrace);
      state = state.copyWith(
        screenShareState: ScreenShareState.error,
        errorMessage: 'Failed to stop screen share: ${e.toString()}',
      );
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get the list of connected participants
  List<Participant> getParticipants() {
    final room = _liveKitService.room;
    if (room == null) return [];

    return [
      room.localParticipant,
      ...room.remoteParticipants.values,
    ].whereType<Participant>().toList();
  }

  /// Get the current room
  Room? get room => _liveKitService.room;

  @override
  void dispose() {
    _liveKitService.dispose();
    super.dispose();
  }
}
