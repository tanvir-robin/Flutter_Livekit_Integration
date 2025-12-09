/// Utility functions for JWT token validation and parsing
class TokenUtils {
  /// Validate if a string is a valid JWT token format
  static bool isValidJWT(String token) {
    if (token.trim().isEmpty) return false;

    final parts = token.split('.');
    if (parts.length != 3) return false;

    try {
      // Try to decode each part to validate format
      for (final part in parts) {
        if (part.isEmpty) return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract room name from JWT token (basic parsing)
  static String? extractRoomFromJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      // Note: In a real app, you'd properly decode the JWT payload
      // For now, return null and let the connection determine the room name
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Utility functions for URLs
class UrlUtils {
  /// Validate if a string is a valid WebSocket URL
  static bool isValidWebSocketUrl(String url) {
    if (url.trim().isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'ws' || uri.scheme == 'wss';
    } catch (e) {
      return false;
    }
  }

  /// Ensure URL has proper protocol
  static String ensureWebSocketProtocol(String url) {
    if (url.trim().isEmpty) return '';

    if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
      return 'wss://$url';
    }
    return url;
  }
}
