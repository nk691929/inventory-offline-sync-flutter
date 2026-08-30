import 'dart:async';

import 'package:collaborative_inventory/features/auth/domain/entities/app_user.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';
import 'package:collaborative_inventory/features/auth/presentations/providers/auth_provider.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:collaborative_inventory/features/inventory/presentations/providers/inventory_providers.dart';
import 'package:collaborative_inventory/features/inventory/presentations/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Viewer role does not see stock edit buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            () => _FakeAuthNotifier(
              const AppUser(
                id: 'v1',
                email: 'viewer@example.com',
                role: UserRole.viewer,
              ),
            ),
          ),
          productsStreamProvider.overrideWith(
            (ref) => Stream.value([
              Product(
                id: 'p1',
                name: 'Test Product',
                quantity: 5,
                lastModified: DateTime.now(),
              ),
            ]),
          ),
          pendingProductIdsProvider.overrideWith(
            (ref) => Stream.value(<String>{}),
          ),
        ],
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
  });

   testWidgets('Manager role does not see stock edit buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            () => _FakeAuthNotifier(
              const AppUser(
                id: 'm1',
                email: 'manager@example.com',
                role: UserRole.manager,
              ),
            ),
          ),
          productsStreamProvider.overrideWith(
            (ref) => Stream.value([
              Product(
                id: 'p1',
                name: 'Test Product',
                quantity: 5,
                lastModified: DateTime.now(),
              ),
            ]),
          ),
          pendingProductIdsProvider.overrideWith(
            (ref) => Stream.value(<String>{}),
          ),
        ],
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
  });
}




class _FakeAuthNotifier extends AuthNotifier {
  final AppUser _user;
  _FakeAuthNotifier(this._user);

  @override
  Future<AppUser?> build() async => _user;
}
