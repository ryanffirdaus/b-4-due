# Backup file format (version 1)

A B4Due backup is a UTF-8 JSON file. It is meant to be readable and stable: the app maps
fields explicitly, so database migrations do not change the format. An example with
fictional data is in [`demo/contoh-cadangan.json`](../demo/contoh-cadangan.json).

```jsonc
{
  "format": "b4due-backup",          // required, identifies the file
  "version": 1,                       // format version; newer files are rejected
  "exportedAt": "2026-10-01T02:00:00.000Z",
  "bills": [ /* Bill */ ],
  "payments": [ /* Payment */ ],
  "settings": { /* only portable keys, see below */ }
}
```

## Bill

| Field | Type | Notes |
|---|---|---|
| `id` | string | UUID (any 1-64 chars of `A-Za-z0-9_-` is accepted) |
| `name` | string | non-empty |
| `category` | string | `electricity`, `water`, `internet`, `phone`, `health`, `vehicleTax`, `installment`, `insurance`, `subscription`, `housing`, `education`, `other`; unknown values become `other` |
| `amount` | int \| null | ≥ 0, in minor units of the file's main currency (`currency.main`; whole rupiah for `IDR`); for a bill in another currency, the latest estimate |
| `amountIsEstimate` | bool | the user's "Nominal ini perkiraan" for a bill in the main currency; false when `originalAmountMinor` is set (older files set it to true there, which readers ignore) |
| `currency` | string | optional, ISO 4217 code, default `IDR`; unknown codes become `IDR` |
| `originalAmountMinor` | int \| null | optional; the price in `currency` minor units (e.g. 2000 = US$20.00); null when `currency` is the main currency |
| `cardColor` | int \| null | optional; wallet-card colour, 0 to 7; null or absent follows the category |
| `installmentTotal`, `installmentNumber` | int \| null | optional; an instalment plan: payments in total and the one due now (1-based); both null or absent for an open-ended bill |
| `dueDate` | string | current unpaid due date, `yyyy-MM-dd` |
| `anchorDay` | int | 1-31, the day of month the user chose |
| `recurrence` | string | `once`, `monthly`, `yearly`, `every5Years`, `everyNMonths` |
| `intervalMonths` | int | 0 for `once`; 1-120 for `everyNMonths` |
| `reminderOffsets` | int[] \| null | days before due (0 = on the day); null = app default |
| `reminderMinuteOfDay` | int \| null | minutes after midnight; null = app default |
| `notes`, `paymentUrl` | string \| null | |
| `createdAt`, `updatedAt` | string | ISO 8601 UTC instant |
| `archivedAt` | string \| null | set when a one-off bill was paid |
| `deletedAt` | string \| null | soft delete |
| `snoozedUntil` | string \| null | pending "Ingatkan besok" instant |

## Payment

| Field | Type | Notes |
|---|---|---|
| `id` | string | UUID |
| `billId` | string | must reference a bill in the same file |
| `dueDate` | string | the period that was paid, `yyyy-MM-dd` |
| `paidAt`, `createdAt` | string | ISO 8601 UTC instant |
| `amount` | int \| null | minor units of `currency`, copied from the bill at the time of payment |
| `currency` | string | optional, ISO 4217 code of the main currency when paid; absent means `IDR` (files from before main currencies) |

## Settings

Only portable keys are exported: `currency.main` (ISO 4217 code; always written, and treated
as `IDR` when a file has none), `reminder.offsets` (JSON array as a string),
`reminder.minuteOfDay`, `budget.monthly` (minor units of the main currency, absent when no
budget is set),
`appearance.theme` (`system`, `light` or `dark`) and
`appearance.accent` (`lime`, `sky`, `coral`, `violet`, `amber` or `mint`). App-lock data
(`lock.*`), onboarding state and the chosen calendar stay on the device. On restore, the main
currency, the budget and the reminder settings are replaced, because the amounts in the file
are in its main currency; the theme and accent change only when the file contains them.

## Compatibility rules

- Readers reject files whose `version` is higher than they understand.
- Adding an optional field does not need a new version; removing or reinterpreting a field does.
- A restore validates the whole file first and then replaces all bills, payments and
  reminder settings in one transaction. A bad file changes nothing.
