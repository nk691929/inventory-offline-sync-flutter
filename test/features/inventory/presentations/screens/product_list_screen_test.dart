import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collaborative_inventory/features/inventory/presentations/screens/product_list_screen.dart';
import 'package:collaborative_inventory/features/inventory/presentations/providers/inventory_providers.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/app_user.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';
import 'package:collaborative_inventory/features/auth/presentations/providers/auth_provider.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final AppUser _user;
  _FakeAuthNotifier(this._user);

  @override
  Future<AppUser?> build() async => _user;
}

List<Override> _baseOverrides(AppUser user) => [
  authNotifierProvider.overrideWith(() => _FakeAuthNotifier(user)),
  productsStreamProvider.overrideWith(
    (ref) => Stream.value([
      Product(id: 'p1', name: 'Test Product', quantity: 5, lastModified: DateTime.now()),
    ]),
  ),
  pendingProductIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
  failedProductIdsProvider.overrideWith((ref) => Stream.value(<String>{})), 
];

void main() {
  testWidgets('Viewer role does not see stock edit buttons or Add Product', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          const AppUser(id: 'v1', email: 'viewer@example.com', role: UserRole.viewer),
        ),
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing); 
  });

  testWidgets('Manager role sees stock edit buttons and Add Product', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseOverrides(
          const AppUser(id: 'm1', email: 'manager@example.com', role: UserRole.manager),
        ),
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}