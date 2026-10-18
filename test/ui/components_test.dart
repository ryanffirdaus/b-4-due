import 'package:b4due/core/time/local_date.dart';
import 'package:b4due/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

final _today = LocalDate(2026, 8, 10);

/// Pumps [build] inside the app frame, rebuilding it on [setState].
Future<void> _pump(
  WidgetTester tester,
  Widget Function(BuildContext context, StateSetter setState) build,
) => pumpScreen(
  tester,
  B4Scaffold(body: StatefulBuilder(builder: build)),
  today: _today,
);

void main() {
  testWidgets('switch toggles and reports its state', (tester) async {
    final semantics = tester.ensureSemantics();
    var on = false;
    await _pump(
      tester,
      (context, setState) => B4SwitchRow(
        title: 'Kunci dengan PIN',
        value: on,
        onChanged: (v) => setState(() => on = v),
      ),
    );

    await tester.tap(find.text('Kunci dengan PIN'));
    await tester.pumpAndSettle();
    expect(on, isTrue);
    expect(
      tester.getSemantics(find.byType(B4ListRow)),
      isSemantics(
        label: 'Kunci dengan PIN',
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('chips report selection and call back', (tester) async {
    var selected = 'Bulanan';
    await _pump(
      tester,
      (context, setState) => Wrap(
        children: [
          for (final label in ['Sekali', 'Bulanan'])
            B4Chip(
              label: label,
              selected: selected == label,
              onTap: () => setState(() => selected = label),
            ),
        ],
      ),
    );
    await tester.tap(find.text('Sekali'));
    await tester.pumpAndSettle();
    expect(selected, 'Sekali');
  });

  testWidgets('text form field shows the validator message, then accepts '
      'input', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(
      tester,
      (context, setState) => Form(
        key: formKey,
        child: B4TextFormField(
          controller: controller,
          label: 'Nama tagihan',
          validator: (text) => text.trim().isEmpty ? 'Isi nama tagihan.' : null,
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Isi nama tagihan.'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Listrik PLN');
    expect(controller.text, 'Listrik PLN');
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Isi nama tagihan.'), findsNothing);
  });

  testWidgets('long-pressing text opens the app\'s own copy menu', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Pelanggan');
    addTearDown(controller.dispose);
    await _pump(
      tester,
      (context, setState) =>
          B4TextField(controller: controller, label: 'Catatan'),
    );
    await tester.longPress(find.byType(EditableText));
    await tester.pumpAndSettle();
    expect(find.byType(B4TextContextMenu), findsOneWidget);

    await tester.tap(find.text('Pilih semua'));
    await tester.pumpAndSettle();
    expect(controller.selection.textInside(controller.text), 'Pelanggan');
    expect(find.text('Salin'), findsOneWidget);
    expect(find.text('Potong'), findsOneWidget);
  });

  testWidgets('date picker returns the tapped day', (tester) async {
    LocalDate? picked;
    await _pump(
      tester,
      (context, setState) => B4Button(
        label: 'Pilih tanggal',
        onPressed: () async {
          picked = await showB4DatePicker(
            context: context,
            initial: _today,
            first: _today.addDays(-30),
            last: _today.addMonths(24),
          );
        },
      ),
    );
    await tester.tap(find.text('Pilih tanggal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(picked, LocalDate(2026, 8, 20));
  });

  testWidgets('date picker jumps to another year', (tester) async {
    LocalDate? picked;
    await _pump(
      tester,
      (context, setState) => B4Button(
        label: 'Pilih tanggal',
        onPressed: () async {
          picked = await showB4DatePicker(
            context: context,
            initial: _today,
            first: _today,
            last: _today.addMonths(60),
          );
        },
      ),
    );
    await tester.tap(find.text('Pilih tanggal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agustus 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2031'));
    await tester.pumpAndSettle();
    expect(find.text('Agustus 2031'), findsOneWidget);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(picked, LocalDate(2031, 8, 10));
  });

  testWidgets('time picker keeps the initial time when confirmed', (
    tester,
  ) async {
    int? picked;
    await _pump(
      tester,
      (context, setState) => B4Button(
        label: 'Jam pengingat',
        onPressed: () async {
          picked = await showB4TimePicker(
            context: context,
            initialMinuteOfDay: 19 * 60 + 30,
          );
        },
      ),
    );
    await tester.tap(find.text('Jam pengingat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(picked, 19 * 60 + 30);
  });

  testWidgets('toast action runs once and the toast goes away', (tester) async {
    var undone = 0;
    await _pump(
      tester,
      (context, setState) => B4Button(
        label: 'Bayar',
        onPressed: () => B4Toast.of(context).show(
          'Dicatat lunas',
          actionLabel: 'Batalkan',
          onAction: () => undone++,
        ),
      ),
    );
    await tester.tap(find.text('Bayar'));
    await tester.pumpAndSettle();
    expect(find.text('Dicatat lunas'), findsOneWidget);

    await tester.tap(find.text('Batalkan'));
    await tester.pumpAndSettle();
    expect(undone, 1);
    expect(find.text('Dicatat lunas'), findsNothing);
  });

  testWidgets('toast hides itself after its duration', (tester) async {
    await _pump(
      tester,
      (context, setState) => B4Button(
        label: 'Simpan',
        onPressed: () => B4Toast.of(context).show('Tersimpan'),
      ),
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Tersimpan'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Tersimpan'), findsNothing);
  });

  testWidgets('confirm dialog resolves true only on confirm', (tester) async {
    bool? result;
    await _pump(
      tester,
      (context, setState) => B4Button(
        label: 'Hapus',
        onPressed: () async {
          result = await showB4Confirm(
            context: context,
            title: 'Hapus tagihan ini?',
            body: 'Pengingatnya akan berhenti.',
            confirmLabel: 'Hapus tagihan',
            destructive: true,
          );
        },
      ),
    );
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus tagihan'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
