import 'package:b4due/app/theme.dart';
import 'package:b4due/core/providers.dart';
import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// A typical mid-range Android phone: 1080x2400 at 2.625x.
const phoneSize = Size(1080, 2400);
const phonePixelRatio = 2.625;

/// Pumps [child] inside the app theme and localizations, with "today"
/// pinned to [today] so dates in screenshots never change.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  required LocalDate today,
  List<Override> overrides = const [],
  Locale locale = const Locale('id'),
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) async {
  await initializeDateFormatting('id');
  await initializeDateFormatting('en');
  tester.view
    ..physicalSize = phoneSize
    ..devicePixelRatio = phonePixelRatio;
  addTearDown(tester.view.reset);

  final now = DateTime(today.year, today.month, today.day, 10);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [clockProvider.overrideWithValue(() => now), ...overrides],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(brightness),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
