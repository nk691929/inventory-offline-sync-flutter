import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';

class AppUser {
  final String id;
  final String email;
  final UserRole role;

  const AppUser({required this.id, required this.email, required this.role});
}
