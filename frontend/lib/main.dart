import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sub_dashboard_screen.dart';
import 'screens/profile_detail_screen.dart';
import 'models/user_base.dart';
import 'models/sub_user.dart';
import 'services/api_service.dart';
import 'utils/constants.dart';
import 'utils/session_manager.dart';

/// App entry point — checks backend connection then starts the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final connected = await api.checkConnection();
  print(connected ? '✅ Backend Connected!' : '❌ Backend not reachable');
  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────
// AUTH PROVIDER
//
// Global state manager for authentication.
// Accessible from any widget via context.read<AuthProvider>()
// or context.watch<AuthProvider>().
// ─────────────────────────────────────────────────────────────────

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _role; // "main" or "sub"
  String? _email;
  String? _userName;

  /// The logged-in user's USER ACCOUNT UUID (from users table).
  ///
  /// IMPORTANT — Two different UUIDs exist:
  ///   1. auth.userID  = users.id         (the user's account UUID)
  ///   2. profile.id   = profiles.id      (the profile's own UUID)
  ///   3. profile.ownerUserId = profiles.user_id (links profile to account)
  ///
  /// To check ownership: profile.ownerUserId == auth.userID
  /// This is what isOwnProfile() does.
  ///
  /// For main users this is null — they have no database account record.
  String? _userID;

  String? _errorMessage;
  bool _isLoading = false;

  /// Local cache of sub user profiles.
  /// Stores photo bytes (Uint8List) so images survive navigation.
  final List<UserBase> _subUsers = [];

  final ApiService _apiService = ApiService();

  // ── Public getters ─────────────────────────────────────────────
  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  String? get email => _email;
  String? get userName => _userName;
  String? get userID => _userID;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<UserBase> get subUsers => List.unmodifiable(_subUsers);
  ApiService get apiService => _apiService;

  /// True when logged in as one of the 3 hardcoded main users
  bool get isMainUser => _role == 'main';

  /// True when logged in as a registered sub user
  bool get isSubUser => _role == 'sub';

  /// Returns the Flutter profile_1/2/3 ID for the logged-in main user.
  /// Used to show the edit button only on their own main profile card.
  String? get ownProfileId =>
      _email != null ? MainUserConfig.getProfileId(_email!) : null;

  // ── Session restoration ────────────────────────────────────────

  /// Restore auth state from browser localStorage on app startup.
  ///
  /// WHY: Flutter Web loses all in-memory state on page refresh.
  /// localStorage survives refreshes, so we save the token and role
  /// there and restore them here before building the router.
  ///
  /// Returns true if a valid session was found and restored.
  bool restoreSession() {
    final session = SessionManager.loadSession();
    if (session == null) return false;

    _token = session['token'];
    _role = session['role'] ?? 'sub';
    _email = session['email'];
    _userName = session['name'];
    _userID = session['userId']; // Restored from localStorage

    if (_token != null) {
      _apiService.setToken(_token!);
    }

    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  // ── Login ──────────────────────────────────────────────────────

  /// Authenticate with email and password.
  /// Backend checks hardcoded main users first, then the database.
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

        // Extract the user account UUID using the helper
        _userID = _extractUserID(response);

        _apiService.setToken(_token!);
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;

        // Save to localStorage so page refresh restores the session
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

  // ── Register ───────────────────────────────────────────────────

  /// Register a new sub user account.
  /// Backend auto-creates a default profile so the user appears
  /// in the sub dashboard immediately after registration.
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

  // ── Logout ─────────────────────────────────────────────────────

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

  // ── Sub user cache ─────────────────────────────────────────────

  /// Add a new sub user to the local cache.
  void addSubUser(UserBase user) {
    _subUsers.add(user);
    notifyListeners();
  }

  /// Update or insert a sub user in the local cache.
  /// Preserves photo bytes so images survive navigation.
  void updateSubUser(UserBase user) {
    final index = _subUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _subUsers[index] = user;
    } else {
      _subUsers.add(user);
    }
    notifyListeners();
  }

  /// Remove a sub user from the local cache.
  void removeSubUser(String id) {
    _subUsers.removeWhere((user) => user.id == id);
    notifyListeners();
  }

  // ── Ownership check ────────────────────────────────────────────

  /// Check if the logged-in sub user owns the given profile.
  ///
  /// HOW THIS WORKS:
  ///   Every profile in the database has a user_id column that stores
  ///   the UUID of the user account that created it.
  ///
  ///   In Flutter, SubUser.fromJson() reads this as ownerUserId.
  ///   auth.userID is the logged-in user's account UUID.
  ///
  ///   When they match, the logged-in user owns the profile.
  ///
  /// WHY WE CAST TO SubUser:
  ///   UserBase (the parent class) does not have ownerUserId.
  ///   Only SubUser has this field because main profiles don't
  ///   need an owner check (they use a different system).
  ///
  /// Returns false for:
  ///   - Main users (they use ownProfileId instead)
  ///   - When _userID is null (no account UUID available)
  ///   - When profile is not a SubUser instance
  bool isOwnProfile(UserBase profile) {
    // Must be logged in as a sub user with a known account UUID
    if (_userID == null) return false;

    // Cast to SubUser to access the ownerUserId field
    // UserBase does not have this field — only SubUser does
    if (profile is SubUser) {
      // Compare the profile's owner UUID with the logged-in user's UUID
      return profile.ownerUserId == _userID;
    }

    return false;
  }

  // ── Private helpers ────────────────────────────────────────────

  /// Extract the user account UUID from an API response.
  ///
  /// The backend may return the user ID in different locations:
  ///   - Standard: response['user']['id'] (login/register response)
  ///   - Fallback: response['id'] (some simplified responses)
  ///
  /// Returns null for main users (they have no database account).
  String? _extractUserID(Map<String, dynamic> response) {
    // Try the standard location first: response.user.id
    if (response['user'] != null && response['user'] is Map) {
      final userId = response['user']['id']?.toString();
      if (userId != null && userId.isNotEmpty) return userId;
    }

    // Try direct response['id'] as fallback
    final directId = response['id']?.toString();
    if (directId != null && directId.isNotEmpty) return directId;

    return null;
  }
}

// ─────────────────────────────────────────────────────────────────
// ROUTER
//
// Built AFTER AuthProvider so it can call restoreSession()
// to decide whether to start at /login or /dashboard.
// ─────────────────────────────────────────────────────────────────

GoRouter _buildRouter(AuthProvider auth) {
  return GoRouter(
    // Check localStorage before deciding initial route
    initialLocation: auth.restoreSession() ? '/dashboard' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // All users land here first after login
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      // Shows all registered sub user profiles
      GoRoute(
        path: '/sub-dashboard',
        builder: (context, state) => const SubDashboardScreen(),
      ),
      // Works for both main profiles (profile_1/2/3) and sub user UUIDs
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
//
// StatefulWidget so AuthProvider and GoRouter can be created
// in initState before the widget tree builds.
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
    // AuthProvider must be created before router (router calls restoreSession)
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
