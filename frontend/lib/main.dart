import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'models/user_base.dart';
import 'models/sub_user.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sub_dashboard_screen.dart';
import 'screens/pallen_profile/profile_detail_pallen.dart';
import 'screens/profile_detail_karl/profile_detail_karl.dart';
import 'screens/portfolio_aldhy/portfolio_details.dart';
import 'screens/profile_detail_screen.dart';
import 'screens/portfolio_aldhy/portfolio_home.dart';
import 'screens/portfolio_aldhy/portfolio_profile.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();
  final router = _buildRouter(authProvider);
  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: MyApp(router: router),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// SESSION MANAGER
// ─────────────────────────────────────────────────────────────────
class SessionManager {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  static void saveSession({
    required String token,
    required String userID,
    required String email,
    required String userName,
    required bool isMainUser,
  }) {
    html.window.localStorage[_tokenKey] = token;
    html.window.localStorage[_userDataKey] = jsonEncode({
      'user_id': userID,
      'email': email,
      'name': userName,
      'is_main_user': isMainUser,
    });
  }

  static Map<String, dynamic>? loadSession() {
    final token = html.window.localStorage[_tokenKey];
    final userData = html.window.localStorage[_userDataKey];
    if (token == null || userData == null) return null;
    try {
      final data = jsonDecode(userData) as Map<String, dynamic>;
      data['token'] = token;
      return data;
    } catch (_) {
      return null;
    }
  }

  static void clearSession() {
    html.window.localStorage.remove(_tokenKey);
    html.window.localStorage.remove(_userDataKey);
  }
}

// ─────────────────────────────────────────────────────────────────
// HARDCODED MAIN USERS
// ─────────────────────────────────────────────────────────────────
class HardcodedMainUsers {
  static const Map<String, Map<String, String>> _creds = {
    'pallen@main.com': {
      'password': 'YourPasswordHere',
      'name': 'Pallen, Prince Dunhill',
      'id': 'main-pallen-001',
    },
    'karl@main.com': {
      'password': 'YourPasswordHere',
      'name': 'Albaniel, Karl Angelo',
      'id': 'main-karl-002',
    },
    'aldhy@main.com': {
      'password': 'YourPasswordHere',
      'name': 'Fajardo, Aldhy',
      'id': 'main-aldhy-003',
    },
  };

  static Map<String, String>? validate(String email, String password) {
    final user = _creds[email.toLowerCase()];
    if (user == null) return null;
    if (user['password'] != password) return null;
    return Map<String, String>.from(user);
  }

  static bool isMainEmail(String email) =>
      _creds.containsKey(email.toLowerCase());
}

// ─────────────────────────────────────────────────────────────────
// AUTH PROVIDER
// ─────────────────────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  String? _userID;
  String? _email;
  String? _userName;
  String? _token;
  bool _isMainUser = false;
  List<UserBase> _subUsers = [];
  String? _errorMessage;

  // ✅ FIX: Store the logged-in user's profile picture bytes directly.
  // Updated any time the logged-in user edits their own profile picture.
  // This ensures the dashboard badge always reflects the latest image
  // without needing to search through the subUsers list.
  Uint8List? _currentUserPictureBytes;

  final ApiService _apiService = ApiService();

  String? get userID => _userID;
  String? get email => _email;
  String? get userName => _userName;
  String? get token => _token;
  bool get isMainUser => _isMainUser;
  bool get isLoggedIn => _token != null;
  List<UserBase> get subUsers => List.unmodifiable(_subUsers);
  String? get errorMessage => _errorMessage;
  ApiService get apiService => _apiService;
  Uint8List? get currentUserPictureBytes => _currentUserPictureBytes;

  Future<void> tryAutoLogin() async {
    final session = SessionManager.loadSession();
    if (session == null) return;
    _userID = session['user_id']?.toString();
    _email = session['email']?.toString();
    _userName = session['name']?.toString();
    _token = session['token']?.toString();
    _isMainUser = session['is_main_user'] == true;
    if (_token != null) _apiService.setToken(_token!);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    final mainUser = HardcodedMainUsers.validate(email, password);
    if (mainUser != null) {
      final apiResponse = await _apiService.login(email, password);
      if (!apiResponse.containsKey('error') &&
          apiResponse.containsKey('token')) {
        _applyAuthResponse(apiResponse);
        _isMainUser = true;
        SessionManager.saveSession(
          token: _token!,
          userID: _userID!,
          email: _email!,
          userName: _userName!,
          isMainUser: true,
        );
        notifyListeners();
        return true;
      }
      _userID = mainUser['id'];
      _email = email.toLowerCase();
      _userName = mainUser['name'];
      _token = 'main-user-${mainUser['id']}-'
          '${DateTime.now().millisecondsSinceEpoch}';
      _isMainUser = true;
      _subUsers = [];
      _apiService.setToken(_token!);
      SessionManager.saveSession(
        token: _token!,
        userID: _userID!,
        email: _email!,
        userName: _userName!,
        isMainUser: true,
      );
      notifyListeners();
      return true;
    }
    final response = await _apiService.login(email, password);
    if (response.containsKey('error')) {
      _errorMessage = response['error']?.toString();
      notifyListeners();
      return false;
    }
    _applyAuthResponse(response);
    if (!_isMainUser && _userID != null) {
      _loadCurrentUserProfile();
    }

    return true;
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      final response = await _apiService.getProfiles();
      if (response.containsKey('error')) return;

      final List<dynamic> list =
          response['sub_users'] ?? response['profiles'] ?? [];

      // The profile whose user_id matches the logged-in user's ID
      final match = list.where((p) {
        return p['user_id']?.toString() == _userID;
      }).toList();

      if (match.isNotEmpty) {
        final profile =
            SubUser.fromJson(Map<String, dynamic>.from(match.first as Map));
        addSubUser(profile);
      }
    } catch (_) {
      // Silently fail — badge will fall back to default avatar
    }
  }

  Future<void> loginWithToken(Map<String, dynamic> response) async {
    _applyAuthResponse(response);
  }

  void _applyAuthResponse(Map<String, dynamic> r) {
    _token = r['token']?.toString();
    _userID = r['user_id']?.toString() ??
        r['id']?.toString() ??
        (r['user'] as Map<String, dynamic>?)?['id']?.toString();
    _email = r['email']?.toString();
    _userName = r['name']?.toString() ?? r['full_name']?.toString();
    _isMainUser = HardcodedMainUsers.isMainEmail(_email ?? '');
    _subUsers = [];
    if (_token != null) {
      _apiService.setToken(_token!);
      SessionManager.saveSession(
        token: _token!,
        userID: _userID ?? '',
        email: _email ?? '',
        userName: _userName ?? '',
        isMainUser: _isMainUser,
      );
    }
    notifyListeners();
  }

  void logout() {
    _userID = null;
    _email = null;
    _userName = null;
    _token = null;
    _isMainUser = false;
    _subUsers = [];
    _errorMessage = null;
    _currentUserPictureBytes = null; // ✅ clear on logout
    SessionManager.clearSession();
    _apiService.setToken('');
    notifyListeners();
  }

  // ── Sub user list management ──────────────────────────────────────

  void addSubUser(UserBase user) {
    if (_subUsers.any((u) => u.id == user.id)) {
      updateSubUser(user);
    }
    _subUsers = [..._subUsers, user];
    notifyListeners();
  }

  void removeSubUser(String id) {
    _subUsers = _subUsers.where((u) => u.id != id).toList();
    notifyListeners();
  }

  /// ✅ FIX: When the updated profile belongs to the currently
  /// logged-in user, also update [_currentUserPictureBytes] so the
  /// dashboard badge rebuilds immediately without a reload.
  void updateSubUser(UserBase updated) {
    _subUsers = _subUsers.map((u) {
      return u.id == updated.id ? updated : u;
    }).toList();

    // Sync badge picture if editing own profile
    if (updated is SubUser) {
      final bool isOwnProfile =
          updated.ownerUserId == _userID || updated.id == _userID;
      if (isOwnProfile && updated.profilePictureBytes != null) {
        _currentUserPictureBytes = updated.profilePictureBytes;
      }
    }
    notifyListeners();
  }

  /// ✅ NEW: Directly set the current user's badge picture bytes.
  /// Called by [EditSubUserDialog] after a successful photo upload
  /// when the user is editing their own profile.
  void setCurrentUserPicture(Uint8List bytes) {
    _currentUserPictureBytes = bytes;
    notifyListeners();
  }

  bool isOwnProfile(UserBase user) {
    if (_userID == null) return false;

    if (!_isMainUser) {
      if (user is SubUser) {
        return user.ownerUserId ==
            _userID; // ← account UUID matches account UUID ✅
      }
      return user.id == _userID;
    }

    return _isMainUser; // main users own everything
  }
}

// ─────────────────────────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────────────────────────
GoRouter _buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final isLoggedIn = auth.isLoggedIn;
      final loc = state.matchedLocation;
      final isProtected = loc == '/dashboard' ||
          loc == '/sub-dashboard' ||
          loc.startsWith('/profile') && !loc.startsWith('/portfolio');
      if (isProtected && !isLoggedIn) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          ),
        ),
      ),
      GoRoute(
          path: '/sub-dashboard',
          builder: (_, __) => const SubDashboardScreen()),
      GoRoute(
          path: '/profile-pallen',
          builder: (_, __) => const ProfileDetailPallen()),
      GoRoute(
          path: '/profile-karl', builder: (_, __) => const ProfileDetailKarl()),
      GoRoute(
          path: '/profile-aldhy', builder: (_, __) => const PortfolioDetails()),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) => ProfileDetailScreen(
          profileId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
          path: '/portfolio-home', builder: (_, __) => const PortfolioHome()),
      GoRoute(
          path: '/portfolio-profile',
          builder: (_, __) => const PortfolioProfile()),
      GoRoute(
          path: '/portfolio-details',
          builder: (_, __) => const PortfolioDetails()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileDetailScreen(
          profileId: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────
// MY APP
// ─────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PiraTern Profiles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A017),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
