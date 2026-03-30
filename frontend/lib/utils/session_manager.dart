// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// SessionManager persists auth state in the browser's localStorage.
///
/// WHY THIS IS NEEDED:
/// Flutter Web apps lose all in-memory state when the browser is refreshed.
/// Without this, every page refresh logs the user out and clears their role.
/// localStorage survives refreshes and persists until explicitly cleared.
///
/// HOW IT WORKS:
/// - After login/register: saveSession() writes token + role + name to localStorage
/// - On app startup: loadSession() reads them back and restores AuthProvider state
/// - On logout: clearSession() removes all keys from localStorage
///
/// SECURITY NOTE:
/// localStorage is accessible via JavaScript. For higher security,
/// consider using httpOnly cookies (requires backend changes).
/// For a local development app, localStorage is acceptable.
class SessionManager {
  /// localStorage key for the JWT authentication token
  static const String _tokenKey = 'auth_token';

  /// localStorage key for the user role ("main" or "sub")
  static const String _roleKey = 'auth_role';

  /// localStorage key for the logged-in user's email address
  static const String _emailKey = 'auth_email';

  /// localStorage key for the logged-in user's display name
  static const String _nameKey = 'auth_name';

  /// localStorage key for the logged-in sub user's database UUID
  /// This is null for main users (they have no DB record)
  static const String _userIdKey = 'auth_user_id';

  /// Save the current auth session to localStorage.
  ///
  /// Called after every successful login or registration.
  /// This ensures a page refresh restores the correct user and role.
  static void saveSession({
    required String token,
    required String role,
    required String email,
    required String name,
    String? userId,
  }) {
    html.window.localStorage[_tokenKey] = token;
    html.window.localStorage[_roleKey] = role;
    html.window.localStorage[_emailKey] = email;
    html.window.localStorage[_nameKey] = name;

    if (userId != null) {
      html.window.localStorage[_userIdKey] = userId;
    } else {
      // Main users don't have a DB user ID — remove the key
      html.window.localStorage.remove(_userIdKey);
    }
  }

  /// Load the saved auth session from localStorage.
  ///
  /// Returns a map of all session values if a valid session exists.
  /// Returns null if no session has been saved (user not logged in).
  static Map<String, String?>? loadSession() {
    final token = html.window.localStorage[_tokenKey];

    // If no token is saved, there is no valid session
    if (token == null || token.isEmpty) return null;

    return {
      'token': token,
      'role': html.window.localStorage[_roleKey],
      'email': html.window.localStorage[_emailKey],
      'name': html.window.localStorage[_nameKey],
      'userId': html.window.localStorage[_userIdKey],
    };
  }

  /// Remove all auth data from localStorage.
  ///
  /// Called on logout to ensure a refresh doesn't restore the old session.
  static void clearSession() {
    html.window.localStorage.remove(_tokenKey);
    html.window.localStorage.remove(_roleKey);
    html.window.localStorage.remove(_emailKey);
    html.window.localStorage.remove(_nameKey);
    html.window.localStorage.remove(_userIdKey);
  }

  /// Returns true if a valid auth token exists in localStorage.
  /// Used to decide whether to restore session on app startup.
  static bool hasSession() {
    final token = html.window.localStorage[_tokenKey];
    return token != null && token.isNotEmpty;
  }
}
