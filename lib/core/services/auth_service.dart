import '../../features/user_management/domain/entities/user.dart';

/// Service to manage current logged in user session and permissions
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool _isAdminMode = false;

  /// Get current logged in user
  User? get currentUser => _currentUser;

  /// Check if current session is admin
  bool get isAdmin => _isAdminMode || (_currentUser?.email == 'admin@gmail.com');

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null || _isAdminMode;

  /// Set current logged in user
  void setCurrentUser(User user) {
    _currentUser = user;
    // Check if this is admin account
    _isAdminMode = user.email == 'admin@gmail.com';
  }

  /// Set admin mode (for skip login)
  void setAdminMode() {
    _isAdminMode = true;
    _currentUser = null;
  }

  /// Check if user can edit a specific user account
  bool canEdit(String username) {
    if (isAdmin) return true; // Admin can edit anyone
    return _currentUser?.username == username; // User can only edit themselves
  }

  /// Check if user can delete a specific user account
  bool canDelete(String username) {
    if (isAdmin) {
      return username != 'admin'; // Admin cannot delete admin account
    }
    // User can delete their own account
    return _currentUser?.username == username;
  }

  /// Logout current user
  void logout() {
    _currentUser = null;
    _isAdminMode = false;
  }

  /// Get display name for current session
  String getDisplayName() {
    if (_isAdminMode) return 'Admin (Skip Login)';
    return _currentUser?.username ?? 'Guest';
  }
}

