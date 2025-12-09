import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/livekit_provider.dart';
import '../utils/livekit_config.dart';
import '../widgets/loading_button.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();
  final _participantController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roomController.text = LiveKitConfig.defaultRoomName;
    _participantController.text =
        'User${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  @override
  void dispose() {
    _roomController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(liveKitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Room'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // API Secret Warning (if not configured)
                if (!LiveKitConfig.hasValidSecret) ...[
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'API Secret Required',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'To generate proper JWT tokens, you need to add your LiveKit API secret to livekit_config.dart. '
                            'You can find it in your LiveKit dashboard under "Reveal secret".',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.link,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Room Connection',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your LiveKit server URL and JWT token to connect',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Connection form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Room',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Room name field
                        TextFormField(
                          controller: _roomController,
                          decoration: const InputDecoration(
                            labelText: 'Room Name',
                            hintText: 'Enter room name to join',
                            prefixIcon: Icon(Icons.meeting_room),
                            helperText: 'Name of the room to join or create',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Room name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Room name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Participant name field
                        TextFormField(
                          controller: _participantController,
                          decoration: const InputDecoration(
                            labelText: 'Participant Name',
                            hintText: 'Your display name',
                            prefixIcon: Icon(Icons.person),
                            helperText: 'Name shown to other participants',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Participant name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Join room button
                LoadingButton(
                  onPressed: appState.isConnecting ? null : _handleConnect,
                  isLoading: appState.isConnecting,
                  icon: Icons.meeting_room,
                  label: 'Join Room',
                ),

                const SizedBox(height: 16),

                // Quick setup tip
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How it Works',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Enter any room name to join or create a room\n'
                          '• Choose a display name for other participants\n'
                          '• Start sharing your screen once connected',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
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
                                'Connection Failed',
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
                              onPressed: () => ref
                                  .read(liveKitProvider.notifier)
                                  .clearError(),
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
      ),
    );
  }

  void _handleConnect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Clear any previous errors
    ref.read(liveKitProvider.notifier).clearError();

    try {
      final roomName = _roomController.text.trim();
      final participantName = _participantController.text.trim();

      // Generate token automatically using the room and participant name
      final token = LiveKitConfig.generateToken(
        roomName: roomName,
        participantName: participantName,
      );

      await ref
          .read(liveKitProvider.notifier)
          .connect(
            url: LiveKitConfig.serverUrl,
            token: token,
            participantName: participantName,
          );

      // Navigate to screen share screen on successful connection
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/screen-share');
      }
    } catch (e) {
      // Error handling is done by the provider
      // UI will automatically update to show the error
    }
  }
}
