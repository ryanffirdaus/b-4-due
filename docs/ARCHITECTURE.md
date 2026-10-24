# Architecture

B4Due is a Flutter app with no backend. The interesting parts are the date arithmetic,
the reminder scheduling, and doing database work from notification actions that run while
the app is closed. This document explains those choices.

## Layout

```
lib/
  main.dart                 start-up: time zone, notifications, database, providers
  ui/                       the app's own UI kit: tokens, theme, icons, components
  app/                      WidgetsApp, app frame, shell, routes (go_router)
  core/
    database/               Drift database, tables, converters, generated migrations
    format/                 Rupiah and Indonesian date formatting
    platform/               small Android method channel (battery, calendar check, FLAG_SECURE)
    time/                   LocalDate (civil date), time zone setup
    providers.dart          shared Riverpod providers
  features/<feature>/
    domain/                 pure Dart: models, rules, use cases, repository interfaces
    data/                   Drift repositories, plugin gateways
    presentation/           screens and widgets
test/                       mirrors lib/, plus goldens/ and migrations
integration_test/           on-device test of the notification action path
drift_schemas/              JSON dump of every released schema version
```

Features: `bills`, `payments`, `reminders`, `home`, `insights` (calendar view and
statistics), `currency`, `templates`, `backup`, `security`, `calendar` (device calendar
export), `battery`, `onboarding`, `settings`.

The UI follows [DESIGN.md](DESIGN.md). There are no Material or Cupertino widgets: the app
runs on `WidgetsApp`, and every control comes from `lib/ui/` (colours and spacing in
`ui/tokens.dart`, read through `context.palette` and `context.text`). A test fails if anything
in `lib/` imports `material.dart` or `cupertino.dart`. The five tabs are a go_router
`StatefulShellRoute` (`app/shell.dart`); detail pages are pushed above the bottom navigation
with the kit's own page transition.

Domain code has no Flutter imports, so the rules are unit-tested without widgets or a device.
State is Riverpod (no code generation); navigation is go_router.

## Dates

Due dates are **civil dates** (`LocalDate`, stored as `yyyy-MM-dd`), not instants. A bill due
on 17 August is due on 17 August whatever the time zone. Times only appear when a reminder is
scheduled: due date + reminder time-of-day, in the device's zone (`flutter_timezone`, falling
back to `Asia/Jakarta`).

Every repeating rule is "every N months" (monthly = 1, yearly = 12, 5-yearly = 60). The next
due date is the current one plus N months, on the bill's **anchor day** clamped to the length
of the month. A bill anchored on the 31st therefore goes 31 Jan → 28 Feb → 31 Mar instead of
drifting to the 28th forever, and 29 February comes back in leap years.

## Reminder scheduling

```
bills + settings + now ──► planNotifications() ──► [PlannedNotification]   (pure)
                                                        │
                                   ReminderSync ◄───────┘
                     cancel(pending − planned), schedule(planned)          (plugin)
```

`planNotifications` is a pure function:

- one reminder per offset (H-7, H-3, H-1, H by default) at the reminder time, skipping times
  already in the past;
- an overdue bill gets the next three daily "terlambat" nudges, refilled on every sync;
- "Ingatkan besok" adds one reminder at the snooze time and suppresses the bill's reminders
  up to that time, so the user is not notified twice;
- only a horizon is scheduled (120 days / 400 notifications on Android, 60 days / 64 on iOS),
  soonest first.

Each reminder has a key `billId|dueDate|kind|discriminator` and an **ID derived from it**
(FNV-1a, 31 bits, with deterministic probing on collisions and reserved IDs). The same input
always yields the same IDs, so `ReminderSync` can cancel whatever is pending but no longer
planned and (re)schedule everything planned. Scheduling an existing ID replaces it, so a sync
is idempotent and can never duplicate a notification. Concurrent sync calls are coalesced.

Sync runs on launch, on resume, after every data change, after a restore, and from a
12-hourly WorkManager task. After a reboot the notification plugin's boot receiver restores
the pending alarms. Exact alarms come from `USE_EXACT_ALARM` on Android 13+ (and the user
grant on Android 12); without them reminders fall back to inexact delivery.

## Notification actions in a background isolate

"Sudah dibayar" and "Ingatkan besok" run in a **separate background isolate**, often while
the app is not running. This path is where these apps usually break, so it is designed
explicitly:

- **One database, many isolates.** The database is opened with drift_flutter's
  `shareAcrossIsolates`: the first isolate that needs it starts a drift server isolate and
  registers it with `IsolateNameServer`; every other isolate in the process (UI, notification
  action, WorkManager) connects to that same server. A payment made from the notification
  therefore updates the open home screen immediately. WAL mode and a busy timeout cover two
  servers racing at start-up.
- **Idempotent use case.** `PayBill` runs in one write-locked transaction, and an action
  carries the due date it was about. It only records a payment if the bill is still on that
  period and the period has not been paid. A double tap, a duplicate delivery, or a stale
  notification for an earlier period does nothing.
- **Same wiring everywhere.** `ReminderRuntime.create()` builds the database, plugin and use
  cases identically in every isolate, and initializes the plugin with the same callbacks, so
  the background handler is never accidentally unregistered.
- **Tests.** Real `Isolate`s against one SQLite file, including six simultaneous deliveries
  of the same action (`test/features/reminders/data/background_action_isolate_test.dart`),
  plus an on-device integration test through the real runtime (`integration_test/`).

## Database and migrations

Drift on SQLite. IDs are UUID v4 strings; bills are soft-deleted so history and backups stay
consistent. Schema versions so far:

| Version | Change |
|---|---|
| 1 | `bills`, `app_settings` |
| 2 | `payments`, `bills.snoozed_until` |
| 3 | `calendar_links` |
| 4 | `bills.currency`, `bills.original_amount_minor`, `cached_rates` |
| 5 | `bills.card_color` |
| 6 | `bills.installment_total`, `bills.installment_number` |
| 7 | `payments.currency`; clears the old forced estimate flag of converted bills |

`drift_dev make-migrations` dumps each version to `drift_schemas/` and generates a
step-by-step migration helper. Tests migrate every older version to every newer one and check
that real rows survive.

SQLite for Android is compiled from the vendored amalgamation in `third_party/sqlite3` by
`package:sqlite3`'s build hook, so release builds download no prebuilt binaries (needed for
F-Droid).

## Backups

The JSON backup format ([BACKUP_FORMAT.md](BACKUP_FORMAT.md)) is mapped field by field, not
derived from the schema, so migrations never change it silently. A restore decodes and
validates the whole file before touching the database, then replaces everything in one
transaction. App-lock secrets, onboarding state and calendar links are device-specific and
never exported. Android Auto Backup includes only the database file.

## Main currency

Totals, the budget, statistics and the widget use one **main currency**, chosen in
Pengaturan from the 31 currencies the European Central Bank publishes (`currency.main`).
A fresh install takes the currency of the phone's region when it is supported; installs from
before this setting keep rupiah.

- `bills.amount` is in minor units of the main currency. Rupiah has no minor units in the
  app, so older data needed no conversion.
- A bill in another currency keeps its own price in `original_amount_minor`; `amount` is the
  estimate. `ExchangeRates.convert` converts any pair through the rupiah table.
- Every payment stores the main currency it was paid in. History is never rewritten; totals
  convert older payments at the latest rate.
- `MainCurrencyService` changes the main currency in one transaction: each bill is re-based
  (`rebasedBill`, lossless because the price is kept), the budget is converted and rounded to
  whole units, and the setting is stored. Without rates for both currencies it refuses
  instead of losing amounts.

## Privacy by construction

`INTERNET` is declared for one purpose: `features/currency` downloads ECB reference rates
from `api.frankfurter.dev` (EUR base, converted to rupiah per unit) with `dart:io`'s
`HttpClient`: GET only, 10 s timeout, no redirects, 64 KB response cap, no cookies or user
data. Rates are cached in the `cached_rates` table and refreshed when older than 12 hours (on
launch, on resume and in the background check); every failure keeps the last cached rates.
After a refresh, bills in another currency than the main one get their `amount` recomputed
from `original_amount_minor`, so reminders, totals and statistics keep working offline.
The manifest still removes `ACCESS_NETWORK_STATE`, and CI fails the release if the APK
requests any permission outside an allowlist (`tool/check_apk_permissions.sh`). Payment links open in the
user's browser via `url_launcher`.

## App lock

Optional. The PIN is stored as PBKDF2-HMAC-SHA256 (100k iterations, random salt; checked
against the RFC 7914 vectors) and verified in constant time off the UI isolate. Wrong PINs are
throttled. The app relocks after 30 seconds in the background; the lock screen sits above the
navigator, hides the app from screen readers, and `FLAG_SECURE` keeps content out of the
recent-apps preview. This is a privacy screen, not encryption of the database.

## Calendar

Opt-in per bill. The calendar permission is requested only on that tap. The event is created
at the reminder time with one alarm per offset. `calendar_links` remembers the event and a
fingerprint of its content, so the event is replaced after the bill is paid or edited and
removed when the bill is deleted. Reconciliation never prompts for permission.

## Testing strategy

| Layer | How |
|---|---|
| Dates, recurrence, planner, policies | pure unit tests |
| Repositories, use cases, backup round trip | in-memory Drift |
| Migrations | schema dumps, every version pair, data integrity |
| Background action | real isolates + one SQLite file; integration test on device |
| UI | widget tests and golden tests (home light/dark/empty/large text, calendar, statistics, subscriptions, bill form incl. USD), compared on Linux |
| Release | permission audit on the built APK in CI |
