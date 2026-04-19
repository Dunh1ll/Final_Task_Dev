import 'dart:convert';
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
import 'screens/profile_detail_pallen.dart';
import 'screens/profile_detail_karl/profile_detail_karl.dart';
import 'screens/profile_detail_aldhy.dart';
import 'screens/profile_detail_screen.dart';
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
// SESSION MANAGER — persists auth token in browser localStorage
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

  Future<void> tryAutoLogin() async {
    final session = SessionManager.loadSession();
    if (session == null) return;

    _userID = session['user_id']?.toString();
    _email = session['email']?.toString();
    _userName = session['name']?.toString();
    _token = session['token']?.toString();
    _isMainUser = session['is_main_user'] == true;

    if (_token != null) {
      _apiService.setToken(_token!);
    }
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
    return true;
  }

  Future<void> loginWithToken(Map<String, dynamic> response) async {
    _applyAuthResponse(response);
  }

  void _applyAuthResponse(Map<String, dynamic> r) {
    _token = r['token']?.toString();
    _userID = r['user_id']?.toString() ?? r['id']?.toString();
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
    SessionManager.clearSession();
    _apiService.setToken('');
    notifyListeners();
  }

  void addSubUser(UserBase user) {
    _subUsers = [..._subUsers, user];
    notifyListeners();
  }

  void removeSubUser(String id) {
    _subUsers = _subUsers.where((u) => u.id != id).toList();
    notifyListeners();
  }

  void updateSubUser(UserBase updated) {
    _subUsers = _subUsers.map((u) {
      return u.id == updated.id ? updated : u;
    }).toList();
    notifyListeners();
  }

  bool isOwnProfile(UserBase user) {
    if (_userID == null) return false;
    if (user is SubUser) {
      return user.ownerUserId == _userID || user.id == _userID;
    }
    return user.id == _userID;
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
          loc.startsWith('/profile');

      if (isProtected && !isLoggedIn) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/sub-dashboard',
        builder: (_, __) => const SubDashboardScreen(),
      ),
      GoRoute(
        path: '/profile-pallen',
        builder: (_, __) => const ProfileDetailPallen(),
      ),
      GoRoute(
        path: '/profile-karl',
        builder: (_, __) => const ProfileDetailKarl(),
      ),
      GoRoute(
        path: '/profile-aldhy',
        builder: (_, __) => const ProfileDetailAldhy(),
      ),
      GoRoute(
        path: '/profile/:id',
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
      title: 'Nakama Profiles',
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
