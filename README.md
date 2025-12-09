# LiveKit Screen Sharing App

A professional Flutter application for real-time screen sharing built with LiveKit WebRTC technology. Features simplified connection flow, remote screen viewing, and cross-platform compatibility with modern architecture.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![LiveKit](https://img.shields.io/badge/LiveKit-000000?style=for-the-badge&logo=livekit&logoColor=white)](https://livekit.io/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

## ✨ Features

### 🚀 Core Functionality
- **Real-time Screen Sharing** - Share device screen with multiple participants
- **Remote Screen Viewing** - View other participants' shared screens in real-time  
- **Click-to-Maximize** - Tap any remote screen to view fullscreen with zoom/pan
- **Background Service** - Continue sharing when app is minimized
- **Simplified Connection** - Easy room joining with just room name and participant name

### 🎨 User Experience  
- **Material Design 3** - Modern, clean interface with adaptive theming
- **Automatic Authentication** - JWT tokens generated automatically
- **Real-time Updates** - Live connection status and participant management
- **Cross-platform** - Works on Android, iOS, Desktop, and Web
- **Permission Handling** - Streamlined permission requests with clear explanations

### 🏗️ Technical Highlights
- **Clean Architecture** - Separation of concerns with modular design
- **Riverpod State Management** - Reactive state updates throughout the app
- **LiveKit WebRTC** - Industry-standard real-time communication
- **Type Safety** - Full Dart type safety with comprehensive error handling
- **Comprehensive Logging** - Structured logging for debugging and monitoring

## 🛠️ Tech Stack

### Framework & Language
- **[Flutter](https://flutter.dev/)** `^3.10.1` - Cross-platform UI framework
- **[Dart](https://dart.dev/)** `^3.10.1` - Programming language

### Core Dependencies
- **[livekit_client](https://pub.dev/packages/livekit_client)** `^2.5.3` - LiveKit WebRTC SDK
- **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod)** `^2.5.1` - State management
- **[permission_handler](https://pub.dev/packages/permission_handler)** `^11.3.1` - Permission management
- **[dart_jsonwebtoken](https://pub.dev/packages/dart_jsonwebtoken)** `^2.13.0` - JWT token generation
- **[flutter_background](https://pub.dev/packages/flutter_background)** `^1.3.0+1` - Background service support

### Development Tools
- **VS Code** / **Android Studio** - Recommended IDEs
- **Flutter DevTools** - Debugging and performance monitoring
- **Dart Analysis** - Static code analysis and linting

## 🌐 About LiveKit

[LiveKit](https://livekit.io/) is an open-source platform for building real-time video, audio, and data applications. It provides:

- **WebRTC Infrastructure** - Scalable real-time communication
- **Cross-platform SDKs** - Support for web, mobile, and desktop
- **Cloud & Self-hosted** - Flexible deployment options
- **Enterprise Ready** - Production-grade reliability and security
- **Developer Friendly** - Simple APIs with comprehensive documentation

LiveKit powers applications for video conferencing, live streaming, virtual events, telehealth, and collaborative tools.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK `>=3.10.1`
- Dart SDK `>=3.10.1`
- Android Studio / VS Code with Flutter extensions
- Device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/livekit-screen-share-flutter.git
   cd livekit-screen-share-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure LiveKit credentials**
   
   Update `lib/utils/livekit_config.dart` with your LiveKit server details:
   ```dart
   class LiveKitConfig {
     static const String serverUrl = 'wss://your-server.livekit.io';
     static const String apiKey = 'your-api-key';
     static const String apiSecret = 'your-api-secret';
   }
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### LiveKit Server Setup

You need a LiveKit server to use this app:

#### Option 1: LiveKit Cloud (Recommended)
1. Sign up at [LiveKit Cloud](https://cloud.livekit.io/)
2. Create a new project
3. Copy your server URL and API credentials
4. Update the config file with your credentials

#### Option 2: Self-hosted Server
1. Follow the [LiveKit deployment guide](https://docs.livekit.io/oss/deployment/)
2. Configure your server settings
3. Update the app configuration

## 📱 Usage

### Connecting to a Room
1. Launch the app
2. Enter a **room name** (e.g., "my-meeting")
3. Enter your **participant name** (e.g., "John Doe")
4. Tap **"Join Room"** - JWT authentication happens automatically

### Screen Sharing
1. Once connected, tap **"Start Screen Share"**
2. Grant screen recording permissions when prompted
3. Your screen is now being shared with other participants
4. Tap **"Stop Screen Share"** to end sharing

### Viewing Remote Screens
1. Remote participants' screens appear as video tiles
2. **Tap any remote screen** to view it fullscreen
3. **Pinch to zoom** and **pan** around the shared screen
4. Tap the back button to return to the main view

### Background Operation
- Screen sharing continues when the app is minimized
- A persistent notification shows the sharing status
- Return to the app anytime to stop sharing or disconnect

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/          # Data models (AppState, etc.)
├── providers/       # Riverpod state management
├── screens/         # UI screens (Connection, ScreenShare)
├── services/        # Business logic (LiveKit, MediaProjection, etc.)
├── utils/           # Utilities (Config, etc.)
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

### Key Components

**State Management**
- `LiveKitProvider` - Manages connection and sharing state
- `AppState` - Immutable state model with reactive updates

**Services**
- `LiveKitService` - WebRTC connection and track management
- `MediaProjectionService` - Android screen capture permissions
- `BackgroundService` - Background operation support
- `LoggingService` - Structured logging and debugging

**UI Screens**
- `ConnectionScreen` - Simplified room joining interface
- `ScreenShareScreen` - Main screen sharing interface with remote viewing

## 🔧 Platform Configuration

### Android
- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Permissions**: Screen recording, microphone, notifications, background execution

Pre-configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS
- **Minimum Version**: iOS 12.0
- **Capabilities**: Screen recording, microphone access, background modes

Pre-configured in `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for screen sharing with audio</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-processing</string>
</array>
```

## 🚦 Build & Deploy

### Development
```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload
flutter run --hot
```

### Production Builds

**Android**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

**iOS**
```bash
# Build for iOS
flutter build ios --release
```

**Desktop**
```bash
# macOS
flutter build macos --release

# Windows  
flutter build windows --release

# Linux
flutter build linux --release
```

## 🔍 Troubleshooting

### Common Issues

**Connection Problems**
- Verify LiveKit server URL and credentials
- Check network connectivity and firewall settings
- Ensure API secret is properly configured

**Permission Issues**
- Grant screen recording permissions in device settings
- Enable microphone access for audio capture
- Allow notifications for background operation status

**Performance Issues**
- Close unnecessary apps to free up resources
- Check device temperature and battery level
- Monitor network bandwidth usage

**Platform-Specific**

*Android*
- Restart app if MediaProjection fails
- Disable battery optimization for the app
- Check that foreground service permissions are granted

*iOS*  
- Ensure iOS version is 12.0 or higher
- Verify background app refresh is enabled
- Restart device if ReplayKit fails to initialize

## 🔒 Security & Privacy

- **End-to-end Encryption** - All WebRTC data is encrypted in transit
- **No Data Storage** - Screen sharing data is not stored locally or remotely
- **Permission Control** - Users have full control over what is shared
- **Secure Authentication** - JWT tokens are generated securely and expire automatically
- **Privacy Compliance** - No personal data collection beyond what's necessary for functionality

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests  
flutter test integration_test/

# Generate test coverage
flutter test --coverage
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[LiveKit Team](https://livekit.io/)** - For the excellent WebRTC platform
- **[Flutter Team](https://flutter.dev/)** - For the amazing cross-platform framework  
- **[Riverpod](https://riverpod.dev/)** - For the robust state management solution
- **Community Contributors** - For feedback, testing, and improvements

## 📞 Support

- 🐛 **Bug Reports**: [Create an Issue](https://github.com/tanvir-robin/Flutter_Livekit_Integration/issues)
- 💡 **Feature Requests**: [Create an Issue](https://github.com/tanvir-robin/Flutter_Livekit_Integration/issues)
- 📖 **Documentation**: [Wiki](https://github.com/tanvir-robin/Flutter_Livekit_Integration/wiki)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/tanvir-robin/Flutter_Livekit_Integration/discussions)

## 👨‍💻 Author

**Tanvir Robin**
- 📧 **Email**: [contact@tanvirrobin.dev](mailto:contact@tanvirrobin.dev)
- 🌐 **Portfolio**: [https://tanvirrobin.dev](https://tanvirrobin.dev)
- 💼 **LinkedIn**: [https://linkedin.com/in/tanvir-robin](https://linkedin.com/in/tanvir-robin)

---

Made with ❤️ using Flutter and LiveKit

*Ready to share screens in real-time? Get started today!* 🚀
