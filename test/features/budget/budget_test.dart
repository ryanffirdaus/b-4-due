import 'package:b4due/core/database/app_database.dart';
import 'package:b4due/features/budget/domain/budget_status.dart';
import 'package:b4due/features/home/presentation/home_screen.dart';
import 'package:b4due/features/settings/data/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../goldens/demo_data.dart';
import '../../support/pump_app.dart';

void main() {
  test('budget status: room left or how far over', () {
    const under = BudgetStatus(budget: 3000000, planned: 2738111);
    expect(under.isOver, isFalse);
    expect(under.difference, 261889);

    const over = BudgetStatus(budget: 2000000, planned: 2738111);
    expect(over.isOver, isTrue);
    expect(over.difference, 738111);

    expect(const BudgetStatus(budget: 5, planned: 5).isOver, isFalse);
  });

  test('the budget is stored, changed and removed', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SettingsRepository(db);

    expect(await repo.getMonthlyBudget(), isNull);
    await repo.setMonthlyBudget(3000000);
    expect(await repo.getMonthlyBudget(), 3000000);
    await repo.setMonthlyBudget(2500000);
    expect(await repo.getMonthlyBudget(), 2500000);
    await repo.setMonthlyBudget(null);
    expect(await repo.getMonthlyBudget(), isNull);
  });

  testWidgets('Beranda shows the room left under the budget', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      today: goldenToday,
      overrides: demoOverrides(budget: 3000000),
    );
    expect(
      find.text('Anggaran Rp 3.000.000 · masih ada ruang Rp 261.889'),
      findsOneWidget,
    );
  });

  testWidgets('Beranda warns when the month goes over budget', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      today: goldenToday,
      overrides: demoOverrides(budget: 2000000),
    );
    expect(find.text('Melebihi anggaran Rp 738.111'), findsOneWidget);
  });

  testWidgets('Beranda says nothing about a budget when none is set', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      today: goldenToday,
      overrides: demoOverrides(),
    );
    expect(find.textContaining('nggaran'), findsNothing);
  });
}
