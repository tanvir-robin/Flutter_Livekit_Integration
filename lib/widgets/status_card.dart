import 'package:flutter/material.dart';
import '../models/app_state.dart';

/// Widget that displays the current application status
class StatusCard extends StatelessWidget {
  final AppState appState;

  const StatusCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getStatusText(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getStatusColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (appState.isConnected) ...[
              const Divider(height: 24),
              _buildConnectionDetails(context),
            ],

            if (appState.isScreenSharing) ...[
              const Divider(height: 24),
              _buildScreenShareDetails(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    if (appState.isConnected) {
      if (appState.isScreenSharing) {
        iconData = Icons.screen_share;
        iconColor = Theme.of(context).colorScheme.primary;
      } else {
        iconData = Icons.link;
        iconColor = Theme.of(context).colorScheme.primary;
      }
    } else if (appState.isConnecting) {
      iconData = Icons.sync;
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (appState.hasError) {
      iconData = Icons.error_outline;
      iconColor = Theme.of(context).colorScheme.error;
    } else {
      iconData = Icons.link_off;
      iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    Widget icon = Icon(iconData, color: iconColor, size: 24);

    // Add rotation animation for connecting state
    if (appState.isConnecting) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 1),
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 2 * 3.14159, // 2π for full rotation
            child: icon,
          );
        },
      );
    }

    return icon;
  }

  String _getStatusText() {
    switch (appState.connectionState) {
      case AppConnectionState.connected:
        if (appState.isScreenSharing) {
          return 'Screen Sharing Active';
        } else {
          return 'Connected to Room';
        }
      case AppConnectionState.connecting:
        return 'Connecting...';
      case AppConnectionState.reconnecting:
        return 'Reconnecting...';
      case AppConnectionState.error:
        return 'Connection Error';
      case AppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (appState.connectionState) {
      case AppConnectionState.connected:
        return Theme.of(context).colorScheme.primary;
      case AppConnectionState.connecting:
      case AppConnectionState.reconnecting:
        return Theme.of(context).colorScheme.primary;
      case AppConnectionState.error:
        return Theme.of(context).colorScheme.error;
      case AppConnectionState.disconnected:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildConnectionDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          'Room',
          appState.roomName ?? 'Unknown',
          Icons.meeting_room,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Participant',
          appState.participantName ?? 'Unknown',
          Icons.person,
        ),
      ],
    );
  }

  Widget _buildScreenShareDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(context, 'Screen Share', 'Active', Icons.screen_share),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Background',
          appState.isBackgroundEnabled ? 'Enabled' : 'Disabled',
          Icons.radio_button_checked,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
