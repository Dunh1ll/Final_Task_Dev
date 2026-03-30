import 'dart:convert';
import 'package:http/http.dart' as http;

/// ApiService handles ALL HTTP communication with the Go backend.
///
/// Every method returns a Map<String, dynamic> so callers can check:
///   - response.containsKey('error') → something went wrong
///   - response.containsKey('token') → auth success
///   - response['sub_users'] → profile list data
///
/// The backend always wraps responses in { success: bool, data: {...} }.
/// The _unwrap() helper extracts the inner 'data' object automatically.
class ApiService {
  /// Base URL of the Go backend server
  static const String baseUrl = 'http://localhost:8080';

  /// JWT token stored after login/register and re-applied after session restore
  String? _token;

  /// Save the JWT token — called after login, register, and session restore
  void setToken(String token) => _token = token;

  /// Headers for public endpoints (no authentication required)
  Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  /// Headers for protected endpoints (JWT Bearer token required)
  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  // ── Helper ─────────────────────────────────────────────────────

  /// Unwrap the standard backend response envelope.
  ///
  /// Backend always returns: { success: true, data: { ... } }
  /// This extracts the inner 'data' object for easier use.
  /// If no 'data' key exists, returns the body as-is.
  Map<String, dynamic> _unwrap(Map<String, dynamic> body) {
    if (body.containsKey('data') && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data']);
    }
    return body;
  }

  // ── Health check ───────────────────────────────────────────────

  /// Check if the backend server is reachable.
  /// Called on app startup and can be used to diagnose connection issues.
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ── Authentication ─────────────────────────────────────────────

  /// Register a new sub user account.
  ///
  /// On success the backend:
  ///   1. Creates a user record in the users table
  ///   2. Creates a default profile in the profiles table
  ///   3. Returns { token, role: "sub", email, name, user }
  ///
  /// The default profile ensures the new user appears in the sub dashboard
  /// immediately after registration.
  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _publicHeaders,
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _unwrap(body);
      }
      return {
        'error': body['error'] ?? body['message'] ?? 'Registration failed'
      };
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Login with email and password.
  ///
  /// The backend checks hardcoded main users first, then the database.
  /// Returns { token, role: "main"/"sub", email, name } on success.
  /// The role field is critical — it controls all UI permissions.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _publicHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? body['message'] ?? 'Login failed'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  // ── Profile endpoints ──────────────────────────────────────────

  /// Get profiles belonging to the logged-in sub user.
  ///
  /// Calls GET /api/profiles — returns { sub_users: [...], profiles: [...] }
  /// Only returns profiles owned by this specific user (filtered by user_id).
  Future<Map<String, dynamic>> getProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load profiles'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Get ALL sub users across all accounts — main users only.
  ///
  /// Calls GET /api/profiles/all — returns 401 for sub users.
  /// Used by main users on the sub dashboard to see everyone.
  Future<Map<String, dynamic>> getAllSubUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/all'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load sub users'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Get ALL sub users — accessible by ANY authenticated user.
  ///
  /// Calls GET /api/profiles/public
  /// Used by sub users on the sub dashboard so they can see all profiles.
  /// Sub users can view all profiles but can only edit their own.
  Future<Map<String, dynamic>> getPublicProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/public'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load profiles'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Get the 3 hardcoded main profiles from the database.
  Future<Map<String, dynamic>> getMainProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/main'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load profile'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Get a single profile by its UUID.
  ///
  /// Used by ProfileDetailScreen to fetch fresh data from the backend.
  /// The response is merged with local photo bytes in the screen.
  Future<Map<String, dynamic>> getProfileById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/$id'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Profile not found'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Create a new sub user profile and save it to PostgreSQL.
  ///
  /// Called from AddSubUserDialog when the user submits the form.
  /// Returns the created profile including the backend-generated UUID.
  Future<Map<String, dynamic>> createSubUser(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/profiles/sub'),
        headers: _authHeaders,
        body: jsonEncode(profileData),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _unwrap(body);
      }
      return {'error': body['error'] ?? 'Failed to create profile'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Update an existing profile by UUID.
  ///
  /// The backend checks permissions:
  ///   - Main user updating main profile → only if it's their own
  ///   - Main user updating sub user → always allowed (UpdateByID)
  ///   - Sub user updating any profile → only if it's their own
  Future<Map<String, dynamic>> updateProfile(
    String id,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profiles/$id'),
        headers: _authHeaders,
        body: jsonEncode(profileData),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to update profile'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Delete a sub user profile AND their user account permanently.
  ///
  /// Only main users can call this (backend enforces with role check).
  /// After deletion the user can re-register with the same email.
  Future<Map<String, dynamic>> deleteProfile(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/profiles/$id'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return {'success': true};
      return {'error': body['error'] ?? 'Failed to delete profile'};
    } catch (e) {
      return {'error': 'Cannot connect to server.'};
    }
  }
}
