# B4Due design system: Dompet

Bills are cards in a wallet. Each bill is a coloured **wallet card**, the most urgent one at the
front; around them the app stays quiet: an ink-and-lavender page (light) or near-black (dark),
large Sora numbers, full-pill buttons and a floating navigation pill with a round accent "+".
People choose the theme (Terang / Gelap / Ikuti sistem) and each bill's card colour.

B4Due draws every control itself: there are **no Material or Cupertino widgets** in `lib/`
(enforced by `test/ui/no_material_test.dart`). The app runs on `WidgetsApp` and the kit in
`lib/ui/`:

| File | Contents |
|---|---|
| `tokens.dart` | `Palette` (light and dark), `Palette.walletCards`, `Tokens` (spacing, radii, motion) |
| `theme.dart` | `AppText` (type scale), `B4ThemeScope`, `context.palette`, `context.text` |
| `icons.dart` | `RemixIcons`: the subset of Remix Icon the app uses |
| `pressable.dart` | `Pressable`: the tap primitive behind every control |
| `buttons.dart` | `B4Button` (primary, tonal, outline, ghost; destructive), `B4IconButton`, `B4AddButton` |
| `wallet.dart` | `B4WalletCard`, `B4WalletStack`, `B4CardBadge`, `B4ProgressBar` |
| `surfaces.dart` | `B4Card` (panel), `B4ListGroup`, `B4ListRow`, `B4IconTile`, `B4Note`, `B4EmptyState` |
| `controls.dart` | `B4Switch`, `B4SwitchRow`, `B4Chip`, `B4FilterTag` |
| `text_field.dart` | `B4TextField`, `B4TextFormField`, `B4SearchField`, selection handles, text menu |
| `pickers.dart` | `B4FieldButton`, `B4SelectField`, `B4MonthGrid`, date and time pickers |
| `overlays.dart` | `showB4Sheet`, `showB4Dialog`, `showB4Confirm`, `B4Toast` |
| `scaffold.dart` | `B4Scaffold`, `B4TopBar`, `B4PageTitle`, `B4SectionHeader`, `B4BottomNav` |
| `navigation.dart` | page transitions for go_router, `B4Expandable` |

Widgets read colours with `context.palette` and styles with `context.text`, never hard-coded
values. Import everything with `import '../ui/ui.dart';`. A bill's card colours come from
`bill.cardColors` (`lib/features/bills/presentation/bill_labels.dart`).

## Colour

### Page and controls

| Role | Light | Dark | Use |
|---|---|---|---|
| Primary | `#15121D` (ink) | `#F2EEFA` | main buttons, selected tab capsule, selected chips, today in the calendar |
| On primary | `#FFFFFF` | `#0E0C14` | text and icons on primary fills |
| Primary soft | `#E9E5F0` | `#2A2538` | tonal buttons, icon circles |
| Background | `#F3F1F7` | `#0E0C14` | page, splash |
| Surface | `#FFFFFF` | `#1C1828` | panels, sheets, dialogs, navigation pill |
| Surface variant | `#ECE8F2` | `#2A2538` | inputs, unselected chips, switch track |
| Outline / strong | `#E4DFEC` / `#CBC4D8` | `#2A2538` / `#433B57` | dividers / outlined buttons |
| Text / secondary | `#15121D` / `#5E5870` | `#F2EEFA` / `#A9A2BA` | |
| Inverse surface | `#15121D` | `#F2EEFA` | toasts, chart tooltips |

Panels have no outline: light mode lifts them with a soft shadow, dark mode with a lighter
surface.

### Accent

One fixed accent, lime: the add button, progress, the on switch and emphasised text. The fill is
`#B6F36B` with ink text on it; as text on the page it is `#2F6B0C` in light mode and `#B6F36B` in
dark mode, so every pair reaches 4.5:1.

### Wallet cards

Eight diagonal gradients, the same in both themes, all with white text at 4.5:1 or more:
violet, green, red, blue, orange, slate, magenta and teal (`Palette.walletCards`). A bill uses
the colour chosen in its form (Warna kartu), or its category's: Listrik orange, Air and
Pendidikan blue, Internet teal, Pulsa and Langganan violet, BPJS red, Pajak kendaraan and Lainnya
slate, Cicilan magenta, Asuransi and Rumah green.

### Status

Each bill has one status (`BillStatus`), shown as a coloured dot (calendar), a translucent
badge on its wallet card ("TERLAMBAT 2 HARI", "HARI INI") and a tinted chip elsewhere. Colour is
never the only signal: the text always says what the status is. **Mendatang** (upcoming) is
deliberately neutral, so only states that need action are coloured.

| Status | Dot | Text / chip (light) | Text / chip (dark) |
|---|---|---|---|
| Lunas (paid) | `#17B26A` | `#067647` on `#DCFAE6` | `#47CD89` on `#0E3123` |
| Mendatang (upcoming, > 3 days) | `#8E87A0` | `#524B63` on `#ECE8F2` | `#BDB6CC` on `#2A2538` |
| Segera (due within 3 days) | `#F79009` | `#B54708` on `#FEF0C7` | `#FDB022` on `#3A2A08` |
| Hari ini (today) | `#EF6820` | `#B93815` on `#FDEAD7` | `#FF9C66` on `#3D2113` |
| Terlambat (overdue) | `#F04438` | `#B42318` on `#FEE4E2` | `#F97066` on `#3D1916` |
| Dihapus (cancelled) | `#A39CB4` | – | – |

Charts use `Palette.chart`: violet, green, red, blue, orange, magenta, teal and grey in light
mode; lime first and lighter shades in dark mode.

## Typography

[Sora](https://github.com/sora-xor/sora-font) (SIL OFL 1.1), vendored as static weights 400 to
800 cut from the variable font, with tabular figures so amounts line up. Sora has no "≈", so
`tool/add_sora_glyphs.py` adds one built from Sora's tilde, and `test/ui/font_coverage_test.dart`
checks every weight can draw every character in the UI text.

Display 38/30 extra-bold for the month's remaining total and page titles, headline 24/20 bold,
title 18/16, body 16/14, labels 14. **Nothing is smaller than 14sp**, and every screen is
checked at 160 % system font size (golden test `home_large_text.png`); wallet cards grow with
the text.

## Icons

[Remix Icon](https://remixicon.com) **v4.8.0**, the last release under the Apache License 2.0
(later releases use a custom licence). The font is vendored in `assets/fonts/RemixIcon.ttf`
with its licence beside it; release builds tree-shake it to the glyphs in
`lib/ui/icons.dart`. Line icons everywhere; filled icons only for the selected tab. Icons sit on
circles, in a bill's card colours where they stand for that bill.

## Logo

A white calendar card with a lime (`#B6F36B`) header and an ink (`#15121D`) check mark on a
soft ink (`#2A2538`) to ink (`#0E0C14`) gradient (`tool/generate_icons.py`, the adaptive-icon
vectors in `android/app/src/main/res/drawable/`, iOS icons and `docs/images/icon-512.png`). The
notification icon is the same mark as a white silhouette, tinted `#2F6B0C`, which also colours
the phone-calendar events. The logo is our own drawing; Remix Icon's licence
does not allow its icons as a logo. The splash uses the page background (`#F3F1F7` light,
`#0E0C14` dark).

## Shape, spacing and motion

| Token | Value |
|---|---|
| Page padding | 22 |
| Section gap / card gap / list gap | 28 / 16 / 12 |
| Wallet card and panel radius | 22 |
| Buttons | full pill (radius 28), height 56 (compact 44) |
| Inputs | radius 18, height 56; search is a pill |
| Chips | pill, height 40 |
| Dialog / sheet radius | 28 / 30 |
| Navigation pill | height 60, radius 30, 14 from the sides |
| Touch target | at least 48 |
| Motion | 200 ms (300 ms for sheets and page pushes), ease-out cubic |

Pressed controls scale down slightly (to 98 %, icon buttons 92 %) and tint, instead of a ripple.

## Navigation

Five tabs: **Beranda**, **Kalender**, **Langganan**, **Statistik**, **Pengaturan**, as icons in a
pill floating above the page; the active tab is a filled capsule that also shows its label when
it fits (every tab keeps its spoken label). Beside the pill, the round accent **+** adds a bill
from any tab. Each tab keeps its own scroll position. Detail pages slide in above the tabs with
a raised back button. Sheets slide up with a title and a close button, and can be dragged down.

## Screens

- **Beranda**: the date and greeting, then **Sisa tagihan bulan ini** in large type over a
  paid/remaining bar, then **Kartu tagihan**: the upcoming bills as a wallet stack. The front
  card shows the status badge, the first line of the notes (often the customer number; hidden
  when empty), the due date, the price and **Bayar** (with Batalkan); the cards behind show
  their name and countdown. "Semua (n)" opens Langganan.
- **Langganan**: search pill, category filter, and every bill as a compact wallet card with
  Bayar. Swipe right marks paid (with undo), swipe left deletes (asks first).
- **Detail tagihan**: a large wallet card (category, countdown, name, price), Sudah dibayar, then
  a panel of details; long-press a row to copy its value.
- **Form**: filled inputs with the label above; **Warna kartu** offers Otomatis plus the eight
  card colours.
- **Kalender**: month grid in a panel with status dots; a day opens a sheet of small wallet
  cards with their reminder times.
- **Statistik**: the monthly average in large type, the coming 30 days, the most expensive bill
  as its wallet card, and the category and monthly charts.
- **Pengaturan → Tampilan**: Tema (Terang / Gelap / Ikuti sistem, each with a preview) and
  Warna aksen. Both apply at once, are read before the first frame and travel in backups.

## Components

- **Switch**: a pill track that fills with the accent, with a dark knob that keeps its size.
- **Chips**: pills with a leading ring, hollow when off and filled when on, so the choice reads
  without colour; selected chips are filled with the primary colour.
- **Text fields**: label above, ink focus border, error message with an icon below. Long-press
  opens the app's own Potong / Salin / Tempel / Pilih semua menu.
- **Pickers**: dropdowns are sheets; the date picker is a month grid of rounded-square days; the
  time picker has hour and minute steppers plus quick times 07.00, 09.00, 12.00, 17.00 and
  20.00.
- **Dialogs**: an icon circle (red for destructive actions), title, text and two equal pills.
- **Toast**: an inverted pill that drops in at the top with a status circle and an optional
  accent action such as "Batalkan"; swipe up to dismiss.
- **Loading**: three dots pulsing in turn.
- **PIN pad**: raised rounded-square keys, not the round keys of a system lock screen.

## Accessibility (WCAG AA)

- Every text/background pair the kit draws is checked at 4.5:1 or more in both themes, and
  white text on every wallet card too (`test/ui/palette_contrast_test.dart`).
- Status text uses darker (light mode) or lighter (dark mode) shades on a tinted chip, or white
  on a translucent badge on a wallet card.
- Swipe backgrounds use `#067647` (paid) and `#B42318` (delete) behind white icons and text.
- Icon-only buttons and navigation tabs always have a spoken label; switches and selected chips
  report their state.
- Minimum text size is 14sp. Touch targets are at least 48dp.

## Not the platform look

Being drawn by the app is not enough; controls must not *look* like Android (Material) or iOS
defaults either. So there is no ripple, no M3 navigation bar with a pill behind a labelled icon,
no thumb-growing switch, no extended FAB, no check-mark filter chips, no outlined white cards,
no drag handle on sheets, no right-aligned text buttons in dialogs, no dark snackbar at the
bottom, no spinning arc, no wheel or clock time picker, and no round calendar-day or PIN keys.
New components follow the same rule.

The only system UI left is what Android itself draws and the app cannot replace: the
fingerprint prompt, the file picker for backups, the share sheet and notifications.

## Deliberate differences from the original spec

- Notification actions stay "Sudah dibayar" and "Ingatkan besok" (no "View" action; tapping
  the notification opens the bill).
- Swipe left deletes (with confirmation) instead of archiving; one-off bills are archived
  automatically when paid.
- Service logos and payment-method fields are not included; cards show a category icon and
  colour.
