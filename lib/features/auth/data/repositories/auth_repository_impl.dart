import 'package:collaborative_inventory/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/app_user.dart';
import 'package:collaborative_inventory/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository{
  final AuthLocalDatasource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});
  @override
  Future<AppUser?> getPersistedUser() async{
    return localDataSource.readSession();
  }

  @override
  Future<AppUser?> login(String email, String password) async{
     final user = await localDataSource.validateCredentials(email, password);
    if (user != null) {
      await localDataSource.saveSession(user);
    }
    return user;
  }

  @override
  Future<void> logout() async{
    await localDataSource.clearSession();
  }
}