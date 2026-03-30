import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sub_dashboard_screen.dart';
import 'screens/profile_detail_screen.dart';
import 'models/user_base.dart';
import 'services/api_service.dart';
import 'utils/constants.dart';
import 'utils/session_manager.dart';

/// App entry point.
/// Checks backend connection then launches the UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verify backend is reachable on startup
  final api = ApiService();
  final connected = await api.checkConnection();
  print(connected ? '✅ Backend Connected!' : '❌ Backend not reachable');

  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────
// AUTH PROVIDER
//
// AuthProvider is the global state manager for authentication.
// It holds the logged-in user's information and is accessible
// from any widget in the tree via context.read<AuthProvider>()
// or context.watch<AuthProvider>().
//
// It also maintains a local cache of sub users (_subUsers list)
// so that photo bytes (which are not stored in the DB) survive
// navigation between screens within the same session.
// ─────────────────────────────────────────────────────────────────

class AuthProvider extends ChangeNotifier {
  // ── Private state fields ───────────────────────────────────────
  bool _isAuthenticated = false;
  String? _token; // JWT token sent with every API request
  String? _role; // "main" or "sub" — controls UI permissions
  String? _email; // Logged-in user's email address
  String? _userName; // Logged-in user's display name
  String?
      _userID; // DB UUID — only set for sub users (main users have no DB record)
  String? _errorMessage;
  bool _isLoading = false;

  // Local cache of sub user profiles — preserves photo bytes across screens
  final List<UserBase> _subUsers = [];

  // Single ApiService instance shared across the whole app
  final ApiService _apiService = ApiService();

  // ── Public getters ─────────────────────────────────────────────
  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  String? get email => _email;
  String? get userName => _userName;
  String? get userID => _userID;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Returns an unmodifiable copy to prevent external mutation
  List<UserBase> get subUsers => List.unmodifiable(_subUsers);
  ApiService get apiService => _apiService;

  /// True if logged in as one of the 3 hardcoded main users
  bool get isMainUser => _role == 'main';

  /// True if logged in as a registered database sub user
  bool get isSubUser => _role == 'sub';

  /// Returns the Flutter profile_1/2/3 ID for the logged-in main user.
  /// Used to determine which main profile card shows an edit button.
  /// Returns null for sub users.
  String? get ownProfileId =>
      _email != null ? MainUserConfig.getProfileId(_email!) : null;

  // ── Session restoration ────────────────────────────────────────

  /// Restore auth state from browser localStorage on app startup.
  ///
  /// This fixes the page refresh bug:
  /// Without this, refreshing the page clears AuthProvider state
  /// and the user appears to be logged out or switched roles.
  ///
  /// Returns true if a valid session was found and restored.
  bool restoreSession() {
    final session = SessionManager.loadSession();
    if (session == null) return false;

    // Restore all auth fields from localStorage
    _token = session['token'];
    _role = session['role'] ?? 'sub';
    _email = session['email'];
    _userName = session['name'];
    _userID = session['userId'];

    // Re-apply token to ApiService so API calls work immediately
    if (_token != null) {
      _apiService.setToken(_token!);
    }

    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  // ── Login ──────────────────────────────────────────────────────

  /// Authenticate with email and password.
  ///
  /// The backend checks hardcoded main users first, then the database.
  /// On success: stores all auth data in memory AND localStorage.
  /// On failure: stores error message for the UI to display.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Trigger UI to show loading spinner

    try {
      final response = await _apiService.login(email, password);

      if (response.containsKey('token')) {
        // ── Store auth state in memory ─────────────────────────
        _token = response['token'];
        _role = response['role'] ?? 'sub';
        _email = response['email'] ?? email;
        _userName = response['name'] ?? '';

        // Sub users have a DB UUID; main users use hardcoded IDs not in DB
        _userID = response['user'] != null
            ? response['user']['id']?.toString()
            : null;

        _apiService.setToken(_token!); // Apply to all future API calls
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;

        // ── Persist session to localStorage ────────────────────
        // This ensures a page refresh restores the correct user/role
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
        // Backend returned an error (wrong password, user not found, etc.)
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

  /// Register a new sub user account and auto-login.
  ///
  /// The backend creates the user AND a default profile.
  /// The default profile ensures they appear in the sub dashboard
  /// immediately after registration without manual profile creation.
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
        _userID = response['user'] != null
            ? response['user']['id']?.toString()
            : null;
        _apiService.setToken(_token!);
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;

        // Persist so refresh keeps user logged in
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

  /// Clear all auth state from memory AND localStorage.
  ///
  /// After this, a page refresh will show the login screen.
  void logout() {
    _isAuthenticated = false;
    _token = null;
    _role = null;
    _email = null;
    _userName = null;
    _userID = null;
    _errorMessage = null;
    _subUsers.clear(); // Clear cached profiles and their photo bytes

    // Remove from localStorage so refresh doesn't restore old session
    SessionManager.clearSession();

    notifyListeners();
  }

  // ── Sub user cache management ──────────────────────────────────

  /// Add a new sub user to the local cache.
  /// Called after successfully creating a profile via the API.
  void addSubUser(UserBase user) {
    _subUsers.add(user);
    notifyListeners();
  }

  /// Update or insert a sub user in the local cache.
  ///
  /// This is critical for image persistence:
  /// When a user uploads a photo, the bytes are stored here.
  /// Any screen that reads from this cache will get the photo bytes
  /// and display the image correctly — even before backend reload.
  void updateSubUser(UserBase user) {
    final index = _subUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _subUsers[index] = user; // Update existing entry
    } else {
      _subUsers.add(user); // Insert new entry
    }
    notifyListeners();
  }

  /// Remove a sub user from the local cache.
  /// Called after successfully deleting a profile via the API.
  void removeSubUser(String id) {
    _subUsers.removeWhere((user) => user.id == id);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────
// ROUTER FACTORY
//
// The router is built AFTER AuthProvider is created so it can
// check restoreSession() to decide the initial route.
//
// If a valid session exists in localStorage → go to /dashboard
// If no session exists → go to /login
// ─────────────────────────────────────────────────────────────────

GoRouter _buildRouter(AuthProvider auth) {
  return GoRouter(
    // ✅ Check localStorage session before deciding where to start
    // This fixes the "page refresh sends to login" bug
    initialLocation: auth.restoreSession() ? '/dashboard' : '/login',
    routes: [
      // Login screen — public, no auth needed
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register screen — public, no auth needed
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main dashboard — shows 3 main profile carousel
      // ALL users (main and sub) land here first after login
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Sub dashboard — shows all registered sub user profiles
      // Accessible via "Other Profiles" button on main dashboard
      GoRoute(
        path: '/sub-dashboard',
        builder: (context, state) => const SubDashboardScreen(),
      ),

      // Profile detail — shows full info for any profile
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
// MyApp is StatefulWidget (not StatelessWidget) because the router
// depends on AuthProvider, which must be created first.
//
// The Provider wraps everything so AuthProvider is accessible
// from any widget in the entire app.
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
    // Create AuthProvider first so the router can call restoreSession()
    _authProvider = AuthProvider();
    // Build router with auth — it checks localStorage for existing session
    _router = _buildRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      // Use .value because we created the provider in initState
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
