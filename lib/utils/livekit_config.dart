import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Configuration for LiveKit
class LiveKitConfig {
  static const String serverUrl = 'YOUR_LIVEKIT_SERVER_URL_HERE';
  static const String apiKey = 'YOUR_LIVEKIT_API_KEY_HERE';

  // Your actual API secret from LiveKit dashboard
  static const String apiSecret = 'YOUR_LIVEKIT_API_SECRET_HERE';
  // Default room and participant settings
  static const String defaultRoomName = 'screen-share-room';
  static const String defaultParticipantName = 'screen-sharer';

  /// Generate a JWT token for LiveKit authentication
  /// Note: In production, tokens should be generated on your backend server
  /// This is for demo purposes only
  static String generateToken({
    required String roomName,
    required String participantName,
    String? customApiSecret,
  }) {
    try {
      final secret = customApiSecret ?? apiSecret;

      // If no proper secret is provided, return a demo token
      if (secret == 'YOUR_API_SECRET_HERE') {
        return _generateDemoToken(roomName, participantName);
      }

      final now = DateTime.now();
      final expiry = now.add(const Duration(hours: 6));

      // Create JWT payload following LiveKit's exact format
      final payload = {
        'iss': apiKey, // issuer: API key
        'sub': participantName, // subject: participant identity
        'iat': now.millisecondsSinceEpoch ~/ 1000, // issued at
        'exp': expiry.millisecondsSinceEpoch ~/ 1000, // expires
        'nbf': now.millisecondsSinceEpoch ~/ 1000, // not before
        // Video grant following LiveKit's structure
        'video': {
          'room': roomName,
          'roomJoin': true,
          'canPublish': true,
          'canSubscribe': true,
          'canPublishData': true,
          'canUpdateOwnMetadata': true,
          'hidden': false,
          'recorder': false,
        },
      };

      // Create and sign JWT with HS256 algorithm (LiveKit standard)
      final jwt = JWT(payload);
      return jwt.sign(SecretKey(secret), algorithm: JWTAlgorithm.HS256);
    } catch (e) {
      // Fallback to demo token
      return _generateDemoToken(roomName, participantName);
    }
  }

  /// Generate a demo token when proper API secret is not available
  static String _generateDemoToken(String roomName, String participantName) {
    final payload = {
      'room': roomName,
      'participant': participantName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'demo': true,
    };

    // Simple base64 encoding for demo (NOT secure for production)
    return 'demo_${base64Encode(utf8.encode(jsonEncode(payload)))}';
  }

  /// Get pre-configured connection parameters
  static Map<String, String> getConnectionParams({
    String? roomName,
    String? participantName,
    String? customApiSecret,
  }) {
    final room = roomName ?? defaultRoomName;
    final participant = participantName ?? defaultParticipantName;

    return {
      'url': serverUrl,
      'room': room,
      'participant': participant,
      'token': generateToken(
        roomName: room,
        participantName: participant,
        customApiSecret: customApiSecret,
      ),
    };
  }

  /// Validate if proper API secret is configured
  static bool get hasValidSecret =>
      apiSecret.isNotEmpty && apiSecret != 'YOUR_API_SECRET_HERE';
}
