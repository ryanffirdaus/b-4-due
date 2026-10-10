# B4Due design system

A calm, trustworthy "fintech" look: Material 3, one brand colour (Electric Blue), generous
spacing, rounded cards. Everything below is implemented in `lib/app/theme.dart`
(`Palette` for colours, `Tokens` for spacing and radii, `buildAppTheme` for the
Material theme). Widgets read colours with `context.palette`, never hard-coded values.

## Colour

| Role | Light | Dark | Use |
|---|---|---|---|
| Primary (Electric Blue) | `#459AF8` | `#459AF8` | filled buttons, FAB, selected chips, today in the calendar |
| On primary | `#20294C` | `#0B1530` | text and icons on blue fills |
| Primary text | `#1C6DD0` | `#6CB0FA` | links, icons, "≈ Rp …" estimates |
| Midnight Navy | `#20294C` | – | text, snackbar background |
| Background | `#F7F8FC` | `#0F172A` | page |
| Surface / card | `#FFFFFF` | `#1E293B` / `#243247` | cards, sheets, navigation bar |
| Surface variant | `#F0F1F5` | `#243247` | input fills, icon tiles |
| Outline | `#C7CBDB` | `#334155` | card borders, dividers |

### Status

Each bill has one status (`BillStatus`), shown as a coloured dot (calendar) and a tinted chip
with a label (cards). Colour is never the only signal: the chip always carries text such as
"Terlambat 2 hari" or "Hari ini".

| Status | Dot / tint | Text (light) | Text (dark) |
|---|---|---|---|
| Lunas (paid) | `#16A34A` | `#15803D` | `#22C55E` |
| Mendatang (upcoming, > 3 days) | `#3B82F6` | `#2563EB` | `#60A5FA` |
| Segera (due within 3 days) | `#F59E0B` | `#B45309` | `#F59E0B` |
| Hari ini (today) | `#F97316` | `#C2410C` | `#FB923C` |
| Terlambat (overdue) | `#EF4444` | `#DC2626` | `#F87171` |
| Dihapus (cancelled) | `#94A3B8` | – | – |

## Typography

Inter (bundled, SIL OFL 1.1). Display 36/30 bold for page titles and the monthly total,
headline 24/20 semibold, title 18/16, body 16/14, labels 14. **Nothing is smaller than 14sp**,
and every screen is checked at 160 % system font size (golden test `home_large_text.png`).

## Shape and spacing

| Token | Value |
|---|---|
| Page padding | 20 |
| Section gap / card gap / list gap | 24 / 16 / 12 |
| Card radius | 20 |
| Button and input radius, height | 16, 56 |
| Dialog radius | 24 |
| Bottom sheet radius | 28 |
| Bottom navigation | height 80, top corners 24 |
| Motion | 200 ms |

## Navigation

Five tabs: **Beranda**, **Kalender**, **Langganan**, **Statistik**, **Pengaturan**. Each tab
keeps its own scroll position. Detail pages (bill detail, form, history, PIN, battery guide)
open full screen above the tabs with a back button. Bottom sheets open above the navigation bar.

## Components

- **Subscription card**: category tile, name and category, price (foreign currency shows
  "US$20,00 ≈ Rp 357.611"), status chip and due date. Swipe right: mark as paid (with undo).
  Swipe left: delete (asks first). The whole card is one accessible button with a combined label.
- **Monthly spending card**: this month's total, paid versus remaining, and a progress ring
  (decorative; screen readers read the percentage once).
- **Empty state**: illustration tile, title, one sentence, one primary action.

## Accessibility (WCAG AA) adjustments to the original spec

- White on Electric Blue is only 2.9:1, so text and icons on blue use Midnight Navy (4.9:1).
- Status colours from the spec are kept for dots and backgrounds; status *text* uses the darker
  (light mode) or lighter (dark mode) shades above to reach 4.5:1.
- Swipe backgrounds use `#15803D` (paid) and `#DC2626` (delete) behind white icons and text.
- Minimum text size is 14sp instead of 12sp.
- Touch targets are at least 48dp.

## Deliberate differences from the original spec

- Notification actions stay "Sudah dibayar" and "Ingatkan besok" (no "View" action; tapping
  the notification opens the bill).
- Swipe left deletes (with confirmation) instead of archiving; one-off bills are archived
  automatically when paid.
- Service logos and payment-method fields are not included; cards show a category icon.
