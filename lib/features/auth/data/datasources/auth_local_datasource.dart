import 'package:collaborative_inventory/features/auth/domain/entities/app_user.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SeededAccount {
  final String email;
  final String password;
  final UserRole role;
  const _SeededAccount(this.email, this.password, this.role);
}

abstract class AuthLocalDatasource {
  Future<AppUser?> validateCredentials(String email, String password);
  Future<void> saveSession(AppUser user);
  Future<void> clearSession();
  Future<AppUser?> readSession();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _keyEmail = 'session_email';
  static const _keyRole = 'session_role';

  final _seededAccounts = [
    _SeededAccount('admin@example.com', 'admin123', UserRole.admin),
    _SeededAccount('manager@example.com', 'manager123', UserRole.manager),
    _SeededAccount('viewer@example.com', 'viewer123', UserRole.viewer),
  ];

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
  }

  @override
  Future<AppUser?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final roleStr = prefs.getString(_keyRole);
    if (email == null || roleStr == null) return null;
    return AppUser(id: email, email: email, role: UserRole.values.byName(roleStr));
  }

  @override
  Future<void> saveSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, user.email);
    await prefs.setString(_keyRole, user.role.name);
  }

  @override
  Future<AppUser?> validateCredentials(String email, String password) async {
    for (final account in _seededAccounts) {
      if (account.email == email && account.password == password) {
        return AppUser(
          id: account.email,
          email: account.email,
          role: account.role,
        );
      }
    }
    return null;
  }
}
