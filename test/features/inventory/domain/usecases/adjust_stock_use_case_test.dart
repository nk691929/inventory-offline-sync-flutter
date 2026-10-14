
import 'package:collaborative_inventory/features/inventory/domain/usecases/adjust_stock_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late MockInventoryRepository repository;
  late AdjustStockUseCase useCase;

  setUpAll(() {
    // mocktail needs a sample value to use with any() for custom types.
    registerFallbackValue(const Item(id: 'fallback', quantity: 0));
  });

  setUp(() {
    repository = MockInventoryRepository();
    useCase = AdjustStockUseCase(repository);
  });

  group('AdjustStockUseCase', () {
    test('adds delta to quantity and saves the updated item', () async {
      // Arrange
      when(() => repository.getItem('a1'))
          .thenAnswer((_) async => const Item(id: 'a1', quantity: 10));
      when(() => repository.updateItem(any())).thenAnswer((_) async {});

      // Act
      final result = await useCase(itemId: 'a1', delta: -3);

      // Assert
      expect(result.quantity, 7);
      verify(() => repository.updateItem(any(that: isA<Item>()
          .having((i) => i.quantity, 'quantity', 7)))).called(1);
    });

    test('throws and never saves when stock would go negative', () async {
      when(() => repository.getItem('a1'))
          .thenAnswer((_) async => const Item(id: 'a1', quantity: 2));

      await expectLater(
        useCase(itemId: 'a1', delta: -5),
        throwsA(isA<InsufficientStockException>()),
      );
      verifyNever(() => repository.updateItem(any()));
    });
  });
}