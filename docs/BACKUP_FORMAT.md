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
  "settings": { /* only "reminder.*" keys */ }
}
```

## Bill

| Field | Type | Notes |
|---|---|---|
| `id` | string | UUID (any 1-64 chars of `A-Za-z0-9_-` is accepted) |
| `name` | string | non-empty |
| `category` | string | `electricity`, `water`, `internet`, `phone`, `health`, `vehicleTax`, `installment`, `insurance`, `subscription`, `housing`, `education`, `other`; unknown values become `other` |
| `amount` | int \| null | whole rupiah, ≥ 0; for foreign-currency bills, the latest rupiah estimate |
| `amountIsEstimate` | bool | always true for foreign-currency bills |
| `currency` | string | optional, ISO 4217 code, default `IDR`; unknown codes become `IDR` |
| `originalAmountMinor` | int \| null | optional; the price in `currency` minor units (e.g. 2000 = US$20.00); null for `IDR` |
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
| `amount` | int \| null | rupiah at the time of payment |

## Settings

Only portable keys are exported: `reminder.offsets` (JSON array as a string),
`reminder.minuteOfDay` and `appearance.theme` (`system`, `light` or `dark`). App-lock data
(`lock.*`), onboarding state and the chosen calendar stay on the device. On restore, reminder
settings are replaced; the theme changes only when the file contains one.

## Compatibility rules

- Readers reject files whose `version` is higher than they understand.
- Adding an optional field does not need a new version; removing or reinterpreting a field does.
- A restore validates the whole file first and then replaces all bills, payments and
  reminder settings in one transaction. A bad file changes nothing.
