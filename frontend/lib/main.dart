import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sub_dashboard_screen.dart';
import 'screens/profile_detail_screen.dart';
import 'screens/home_screen.dart'; // ✅ NEW
import 'models/user_base.dart';
import 'models/sub_user.dart';
import 'services/api_service.dart';
import 'utils/constants.dart';
import 'utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final connected = await api.checkConnection();
  print(connected ? '✅ Backend Connected!' : '❌ Backend not reachable');
  runApp(const MyApp());
}

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _role;
  String? _email;
  String? _userName;
  String? _userID;
  String? _errorMessage;
  bool _isLoading = false;
  final List<UserBase> _subUsers = [];
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  String? get email => _email;
  String? get userName => _userName;
  String? get userID => _userID;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<UserBase> get subUsers => List.unmodifiable(_subUsers);
  ApiService get apiService => _apiService;
  bool get isMainUser => _role == 'main';
  bool get isSubUser => _role == 'sub';

  String? get ownProfileId =>
      _email != null ? MainUserConfig.getProfileId(_email!) : null;

  bool restoreSession() {
    final session = SessionManager.loadSession();
    if (session == null) return false;
    _token = session['token'];
    _role = session['role'] ?? 'sub';
    _email = session['email'];
    _userName = session['name'];
    _userID = session['userId'];
    if (_token != null) _apiService.setToken(_token!);
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.login(email, password);
      if (response.containsKey('token')) {
        _token = response['token'];
        _role = response['role'] ?? 'sub';
        _email = response['email'] ?? email;
        _userName = response['name'] ?? '';
        _userID = _extractUserID(response);
        _apiService.setToken(_token!);
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;
        SessionManager.saveSession(
          token: _token!,
          role: _role!,
          email: _email!,
          name: _userName!,
          userId: _userID,
        );
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Cannot connect to server.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.register(name, email, password, phone);
      if (response.containsKey('token')) {
        _token = response['token'];
        _role = response['role'] ?? 'sub';
        _email = response['email'] ?? email;
        _userName = response['name'] ?? name;
        _userID = _extractUserID(response);
        _apiService.setToken(_token!);
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;
        SessionManager.saveSession(
          token: _token!,
          role: _role!,
          email: _email!,
          name: _userName!,
          userId: _userID,
        );
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['error'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Cannot connect to server.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _role = null;
    _email = null;
    _userName = null;
    _userID = null;
    _errorMessage = null;
    _subUsers.clear();
    SessionManager.clearSession();
    notifyListeners();
  }

  void addSubUser(UserBase user) {
    _subUsers.add(user);
    notifyListeners();
  }

  void updateSubUser(UserBase user) {
    final index = _subUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _subUsers[index] = user;
    } else {
      _subUsers.add(user);
    }
    notifyListeners();
  }

  void removeSubUser(String id) {
    _subUsers.removeWhere((user) => user.id == id);
    notifyListeners();
  }

  /// Check if the logged-in sub user owns the given profile.
  /// Compares SubUser.ownerUserId with auth.userID.
  bool isOwnProfile(UserBase profile) {
    if (_userID == null) return false;
    if (profile is SubUser) {
      return profile.ownerUserId == _userID;
    }
    return false;
  }

  String? _extractUserID(Map<String, dynamic> response) {
    if (response['user'] != null && response['user'] is Map) {
      final userId = response['user']['id']?.toString();
      if (userId != null && userId.isNotEmpty) return userId;
    }
    final directId = response['id']?.toString();
    if (directId != null && directId.isNotEmpty) return directId;
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────────────────────────

GoRouter _buildRouter(AuthProvider auth) {
  // ✅ Check for existing session
  // If session exists → go to /dashboard (skip home page)
  // If no session → show home page first
  final String initialRoute = auth.restoreSession() ? '/dashboard' : '/';

  return GoRouter(
    initialLocation: initialRoute,
    routes: [
      // ✅ Home page — public landing page (new)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // Login screen
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register screen
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main dashboard
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Sub dashboard
      GoRoute(
        path: '/sub-dashboard',
        builder: (context, state) => const SubDashboardScreen(),
      ),

      // Profile detail
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProfileDetailScreen(profileId: id);
        },
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────
// ROOT WIDGET
// ─────────────────────────────────────────────────────────────────

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = _buildRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp.router(
        title: 'Profile Carousel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
