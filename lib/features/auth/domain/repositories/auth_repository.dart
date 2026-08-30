import 'package:collaborative_inventory/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String email, String password);
  Future<void> logout();
  Future<AppUser?> getPersistedUser();
}