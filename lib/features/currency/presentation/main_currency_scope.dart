import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../currency_providers.dart';
import '../domain/money.dart';

/// Makes the main currency available to every widget below, so formatting
/// code needs no provider access. Read it with `context.mainCurrency`.
class MainCurrencyScope extends InheritedWidget {
  const MainCurrencyScope({
    required this.currency,
    required super.child,
    super.key,
  });

  final Currency currency;

  /// Rupiah when there is no scope (widget tests of single screens).
  static Currency of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MainCurrencyScope>()
          ?.currency ??
      idr;

  @override
  bool updateShouldNotify(MainCurrencyScope oldWidget) =>
      oldWidget.currency != currency;
}

/// [MainCurrencyScope] fed by [mainCurrencyProvider].
class MainCurrencyFrame extends ConsumerWidget {
  const MainCurrencyFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MainCurrencyScope(
    currency: ref.watch(mainCurrencyProvider),
    child: child,
  );
}
