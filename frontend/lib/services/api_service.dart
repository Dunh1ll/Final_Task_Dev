import 'dart:convert';
import 'package:http/http.dart' as http;

/// ApiService handles ALL HTTP communication with the Go backend.
class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /// Unwrap { success: true, data: {...} } response envelope
  Map<String, dynamic> _unwrap(Map<String, dynamic> body) {
    if (body.containsKey('data') && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return body;
  }

  // ── Health ─────────────────────────────────────────────────────
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Auth ───────────────────────────────────────────────────────

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
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _publicHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? body['message'] ?? 'Login failed'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  // ── Forgot Password — 3-step OTP flow ──────────────────────────

  /// Step 1: Send OTP to the user's Gmail
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password/send-otp'),
            headers: _publicHeaders,
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {
        'error': body['error'] ?? body['message'] ?? 'Failed to send OTP'
      };
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Step 2: Verify OTP — returns reset_token on success
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password/verify-otp'),
            headers: _publicHeaders,
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? body['message'] ?? 'Invalid OTP'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  /// Step 3: Reset password using the reset_token
  Future<Map<String, dynamic>> resetPassword(
      String resetToken, String newPassword) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password/reset'),
            headers: _publicHeaders,
            body: jsonEncode({
              'reset_token': resetToken,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? body['message'] ?? 'Reset failed'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  // ── Profiles ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load profiles'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> getAllSubUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/all'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load sub users'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> getPublicProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/public'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load profiles'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> getMainProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/main'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to load profile'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> getProfileById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles/$id'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Profile not found'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> createSubUser(
      Map<String, dynamic> profileData) async {
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
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      String id, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profiles/$id'),
        headers: _authHeaders,
        body: jsonEncode(profileData),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return _unwrap(body);
      return {'error': body['error'] ?? 'Failed to update profile'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }

  Future<Map<String, dynamic>> deleteProfile(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/profiles/$id'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return {'success': true};
      return {'error': body['error'] ?? 'Failed to delete profile'};
    } catch (_) {
      return {'error': 'Cannot connect to server.'};
    }
  }
}
