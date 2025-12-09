enum AppConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

enum ScreenShareState { idle, starting, active, stopping, error }

class AppState {
  final AppConnectionState connectionState;
  final ScreenShareState screenShareState;
  final String? errorMessage;
  final String? roomName;
  final String? participantName;
  final bool isBackgroundEnabled;

  const AppState({
    this.connectionState = AppConnectionState.disconnected,
    this.screenShareState = ScreenShareState.idle,
    this.errorMessage,
    this.roomName,
    this.participantName,
    this.isBackgroundEnabled = false,
  });

  AppState copyWith({
    AppConnectionState? connectionState,
    ScreenShareState? screenShareState,
    String? errorMessage,
    String? roomName,
    String? participantName,
    bool? isBackgroundEnabled,
    bool clearError = false,
  }) {
    return AppState(
      connectionState: connectionState ?? this.connectionState,
      screenShareState: screenShareState ?? this.screenShareState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roomName: roomName ?? this.roomName,
      participantName: participantName ?? this.participantName,
      isBackgroundEnabled: isBackgroundEnabled ?? this.isBackgroundEnabled,
    );
  }

  bool get isConnected => connectionState == AppConnectionState.connected;
  bool get isConnecting => connectionState == AppConnectionState.connecting;
  bool get isScreenSharing => screenShareState == ScreenShareState.active;
  bool get hasError => errorMessage != null;

  @override
  String toString() {
    return 'AppState(connectionState: $connectionState, screenShareState: $screenShareState, errorMessage: $errorMessage, roomName: $roomName, participantName: $participantName, isBackgroundEnabled: $isBackgroundEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.connectionState == connectionState &&
        other.screenShareState == screenShareState &&
        other.errorMessage == errorMessage &&
        other.roomName == roomName &&
        other.participantName == participantName &&
        other.isBackgroundEnabled == isBackgroundEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      connectionState,
      screenShareState,
      errorMessage,
      roomName,
      participantName,
      isBackgroundEnabled,
    );
  }
}
