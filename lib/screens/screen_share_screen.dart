import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import '../providers/livekit_provider.dart';
import '../models/app_state.dart';
import '../widgets/loading_button.dart';
import '../widgets/action_button.dart';
import '../services/livekit_service.dart';
import 'dart:async';

class ScreenShareScreen extends ConsumerStatefulWidget {
  const ScreenShareScreen({super.key});

  @override
  ConsumerState<ScreenShareScreen> createState() => _ScreenShareScreenState();
}

class _ScreenShareScreenState extends ConsumerState<ScreenShareScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(liveKitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Share'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: () => ref.read(liveKitProvider.notifier).disconnect(),
            icon: const Icon(Icons.logout),
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Room info header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.meeting_room,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appState.roomName ?? 'Connected Room',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Participant: ${appState.participantName ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.screen_share,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Screen Sharing',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Screen sharing status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: appState.isScreenSharing
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              appState.isScreenSharing
                                  ? Icons.screen_share
                                  : Icons.stop_screen_share,
                              size: 48,
                              color: appState.isScreenSharing
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              appState.isScreenSharing
                                  ? 'Screen Sharing Active'
                                  : 'Screen Sharing Inactive',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: appState.isScreenSharing
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.isScreenSharing
                                  ? 'Your screen is being shared with other participants'
                                  : 'Start sharing your screen with other participants',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: appState.isScreenSharing
                                        ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withOpacity(0.8)
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.8),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Control buttons
                      if (!appState.isScreenSharing) ...[
                        LoadingButton(
                          onPressed:
                              appState.screenShareState ==
                                  ScreenShareState.starting
                              ? null
                              : () => ref
                                    .read(liveKitProvider.notifier)
                                    .startScreenShare(),
                          isLoading:
                              appState.screenShareState ==
                              ScreenShareState.starting,
                          icon: Icons.screen_share,
                          label: 'Start Screen Share',
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ] else ...[
                        LoadingButton(
                          onPressed:
                              appState.screenShareState ==
                                  ScreenShareState.stopping
                              ? null
                              : () => ref
                                    .read(liveKitProvider.notifier)
                                    .stopScreenShare(),
                          isLoading:
                              appState.screenShareState ==
                              ScreenShareState.stopping,
                          icon: Icons.stop_screen_share,
                          label: 'Stop Screen Share',
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Remote screen shares
              _buildRemoteScreenShares(context),

              const SizedBox(height: 24),

              // Background service info
              if (appState.isScreenSharing) ...[
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Background Service',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Screen sharing is running in the background. You can minimize this app and the sharing will continue.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick actions
              ActionButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ),
                icon: Icons.home,
                label: 'Back to Home',
                description: 'Return to the main screen',
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),

              const SizedBox(height: 16),

              ActionButton(
                onPressed: () => _showDisconnectDialog(context),
                icon: Icons.logout,
                label: 'Leave Room',
                description: 'Disconnect from the current session',
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),

              // Error display
              if (appState.hasError) ...[
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appState.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                ref.read(liveKitProvider.notifier).clearError(),
                            child: Text(
                              'Dismiss',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteScreenShares(BuildContext context) {
    final room = LiveKitService().room;
    if (room == null) {
      return const SizedBox.shrink();
    }

    // Get all remote participants with screen share tracks
    final remoteScreenShares = <Widget>[];

    for (final participant in room.remoteParticipants.values) {
      for (final publication in participant.videoTrackPublications) {
        if (publication.isScreenShare && publication.subscribed) {
          final track = publication.track;
          if (track != null) {
            remoteScreenShares.add(
              _buildRemoteScreenShare(context, participant, track),
            );
          }
        }
      }
    }

    if (remoteScreenShares.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remote Screen Shares',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.desktop_access_disabled,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No Remote Screen Shares',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Other participants are not sharing their screens',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Remote Screen Shares (${remoteScreenShares.length})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...remoteScreenShares,
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteScreenShare(
    BuildContext context,
    lk.RemoteParticipant participant,
    lk.VideoTrack track,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Participant info
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    participant.name.isNotEmpty
                        ? participant.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${participant.name.isNotEmpty ? participant.name : "Unknown"}\'s Screen',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.screen_share,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Video display
          GestureDetector(
            onTap: () => _showMaximizedScreenShare(context, participant, track),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    lk.VideoTrackRenderer(
                      track,
                      fit: lk.VideoViewFit.contain,
                      mirrorMode: lk.VideoViewMirrorMode.off,
                      renderMode: lk.VideoRenderMode.auto,
                      autoCenter: true,
                    ),
                    // Overlay with maximize icon hint
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaximizedScreenShare(
    BuildContext context,
    lk.RemoteParticipant participant,
    lk.VideoTrack track,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(
                '${participant.name.isNotEmpty ? participant.name : "Unknown"}\'s Screen',
                style: const TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Exit Fullscreen',
                ),
              ],
            ),
            body: Center(
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                minScale: 1.0,
                maxScale: 3.0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: lk.VideoTrackRenderer(
                    track,
                    fit: lk.VideoViewFit.contain,
                    mirrorMode: lk.VideoViewMirrorMode.off,
                    renderMode: lk.VideoRenderMode.auto,
                    autoCenter: true,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Room'),
          content: const Text(
            'Are you sure you want to leave the room? This will stop screen sharing and disconnect you from the session.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(liveKitProvider.notifier).disconnect();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }
}
