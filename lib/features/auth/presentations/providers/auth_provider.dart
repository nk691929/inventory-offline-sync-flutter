import 'dart:async';

import 'package:collaborative_inventory/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:collaborative_inventory/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/app_user.dart';
import 'package:collaborative_inventory/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLocalDataSource = Provider<AuthLocalDatasource>(
  (ref) => AuthLocalDatasourceImpl(),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(localDataSource: ref.watch(authLocalDataSource)),
);

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  FutureOr<AppUser?> build() async {
    return ref.watch(authRepositoryProvider).getPersistedUser();
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final repo = ref.watch(authRepositoryProvider);
    final user = await repo.login(email, password);
    state = AsyncData(user);
    return user != null;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);
