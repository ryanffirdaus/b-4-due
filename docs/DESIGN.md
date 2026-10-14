# B4Due design system

A calm, trustworthy look with one brand colour (Plum), generous spacing and rounded cards.
B4Due draws every control itself: there are **no Material or Cupertino widgets** in `lib/`
(enforced by `test/ui/no_material_test.dart`). The app runs on `WidgetsApp` and the kit in
`lib/ui/`:

| File | Contents |
|---|---|
| `tokens.dart` | `Palette` (colours, light and dark) and `Tokens` (spacing, radii, motion) |
| `theme.dart` | `AppText` (type scale), `B4ThemeScope`, `context.palette`, `context.text` |
| `icons.dart` | `RemixIcons`: the subset of Remix Icon the app uses |
| `pressable.dart` | `Pressable`: the tap primitive behind every control |
| `buttons.dart` | `B4Button` (primary, tonal, outline, ghost; destructive), `B4IconButton`, `B4TicketButton` |
| `surfaces.dart` | `B4Card`, `B4ListGroup`, `B4ListRow`, `B4IconTile`, `B4Note`, `B4EmptyState` |
| `controls.dart` | `B4Switch`, `B4SwitchRow`, `B4Chip`, `B4FilterTag` |
| `text_field.dart` | `B4TextField`, `B4TextFormField`, `B4SearchField`, selection handles, text menu |
| `pickers.dart` | `B4FieldButton`, `B4SelectField`, `B4MonthGrid`, date and time pickers |
| `overlays.dart` | `showB4Sheet`, `showB4Dialog`, `showB4Confirm`, `B4Toast` |
| `scaffold.dart` | `B4Scaffold`, `B4TopBar`, `B4PageTitle`, `B4SectionHeader`, `B4BottomNav` |
| `navigation.dart` | page transitions for go_router, `B4Expandable` |

Widgets read colours with `context.palette` and styles with `context.text`, never hard-coded
values. Import everything with `import '../ui/ui.dart';`.

## Logo

A white calendar card with an Ink (`#1F1A2E`) header and a Plum (`#6D28D9`) check mark, on a
diagonal Violet (`#8B5CF6`) to deep Plum (`#4C1D95`) gradient. Sources: the adaptive-icon
vectors in `android/app/src/main/res/drawable/ic_launcher_*.xml` (including a monochrome
version for themed icons) and `tool/generate_icons.py`, which renders the same geometry as PNG
for older Android, iOS and `docs/images/icon-512.png`. The notification icon is the same mark
as a white silhouette, tinted Plum. The splash screen uses the page background (`#F8F6FB`
light, `#14111C` dark). The logo is our own drawing; Remix Icon's licence does not allow its
icons as a logo.

## Colour

Plum was chosen because it collides with none of the status colours, so a coloured chip always
means a state, never the brand. White on Plum is 7.1:1.

| Role | Light | Dark | Use |
|---|---|---|---|
| Primary (Plum) | `#6D28D9` | `#B197FC` | filled buttons, FAB, selected chips and tabs, today in the calendar |
| On primary | `#FFFFFF` | `#1A1033` | text and icons on Plum fills |
| Primary text | `#6D28D9` | `#C4B1FD` | ghost buttons, icons, "≈ Rp …" estimates |
| Primary soft | `#F0EAFB` | `#2E2547` | icon tiles, sheet close button, toast action |
| Background | `#F8F6FB` | `#14111C` | page |
| Surface | `#FFFFFF` | `#1F1A2B` | cards, sheets, dialogs, navigation bar |
| Surface variant | `#F1EDF7` | `#2A2438` | input fills |
| Outline / strong | `#E4DEEC` / `#CFC6DC` | `#2E2740` / `#453C5C` | card borders, dividers / outlined buttons, chips |
| Text / secondary | `#1F1A2E` / `#625B70` | `#EDE9F5` / `#A9A2BA` | |
| Inverse surface | `#1F1A2E` | `#EDE9F5` | chart tooltips |

Charts use `Palette.chart`: Plum first, then sky, teal, amber, magenta, lavender, blue and grey.

### Status

Each bill has one status (`BillStatus`), shown as a coloured dot (calendar) and a chip with a
dot and a label (cards). Colour is never the only signal: the chip always carries text such as
"Terlambat 2 hari" or "Hari ini". **Mendatang** (upcoming) is deliberately neutral, so only
states that need action are coloured.

| Status | Dot | Text / chip (light) | Text / chip (dark) |
|---|---|---|---|
| Lunas (paid) | `#17B26A` | `#067647` on `#DCFAE6` | `#47CD89` on `#0E3123` |
| Mendatang (upcoming, > 3 days) | `#8E87A0` | `#524B63` on `#EFECF4` | `#BDB6CC` on `#2A2438` |
| Segera (due within 3 days) | `#F79009` | `#B54708` on `#FEF0C7` | `#FDB022` on `#3A2A08` |
| Hari ini (today) | `#EF6820` | `#B93815` on `#FDEAD7` | `#FF9C66` on `#3D2113` |
| Terlambat (overdue) | `#F04438` | `#B42318` on `#FEE4E2` | `#F97066` on `#3D1916` |
| Dihapus (cancelled) | `#A39CB4` | – | – |

## Typography

Inter (bundled, SIL OFL 1.1) with tabular figures, so amounts and dates line up. Display 36/30
bold for the monthly total and page titles, headline 24/20 semibold, title 18/16, body 16/14,
labels 14. **Nothing is smaller than 14sp**, and every screen is checked at 160 % system font
size (golden test `home_large_text.png`). Bottom-navigation labels scale down only when a label
is too wide for its slot.

## Icons

[Remix Icon](https://remixicon.com) **v4.8.0**, the last release under the Apache License 2.0
(later releases use a custom licence). The font is vendored in `assets/fonts/RemixIcon.ttf`
with its licence beside it; release builds tree-shake it to the glyphs in
`lib/ui/icons.dart`. Line icons everywhere; filled icons only for the selected tab.

## Shape, spacing and motion

| Token | Value |
|---|---|
| Page padding | 20 |
| Section gap / card gap / list gap | 24 / 16 / 12 |
| Card radius | 20 |
| Button and input radius, height | 16, 56 (compact 44) |
| Chip radius, height | 12, 40 |
| Dialog radius | 24 |
| Bottom sheet radius | 28 |
| Bottom navigation | floating dock, radius 24, 12 from the sides |
| Touch target | at least 48 |
| Motion | 200 ms (280 ms for sheets and page pushes), ease-out cubic |

Pressed controls scale down slightly (to 98 %, icon buttons 92 %) and tint, instead of a ripple.
Cards have a 1px outline; light mode adds a soft shadow, dark mode relies on the outline.

## Navigation

Five tabs: **Beranda**, **Kalender**, **Langganan**, **Statistik**, **Pengaturan**. The tabs sit in
a dock floating above the page edge; the active tab gets a Plum marker hanging from the dock's
top edge (like the tab on a calendar divider) above a filled icon. Each tab keeps its own scroll position. Detail pages
(bill detail, form, history, PIN, battery guide) slide in above the tabs with a back button.
Sheets slide up from the bottom with a title and a close button, and can also be dragged
down to close.

## Components

- **Subscription card**: category tile, name and category, price (foreign currency shows
  "US$20,00 ≈ Rp 357.611"), status chip and due date. Swipe right: mark as paid (with undo).
  Swipe left: delete (asks first).
- **Monthly spending card**: this month's total, paid versus remaining, and a progress ring
  (decorative; screen readers read the percentage once).
- **Add button** (`B4TicketButton`): shaped like a bill ticket, with an icon stub, a dashed
  perforation and notches top and bottom, then the label "Tambah tagihan".
- **Switch**: a squircle track with a square knob that keeps its size; position and fill tell
  the state, no icon in the knob.
- **Chips**: a leading ring, hollow when off and filled when on, so the choice reads without
  colour; selected chips are filled Plum, unselected ones a soft fill without a border.
- **Text fields**: label above the field, Plum focus border, error message with an icon below.
  Long-press opens the app's own Potong / Salin / Tempel / Pilih semua menu, a light card with
  Plum labels.
- **Pickers**: dropdowns are sheets listing the options; the date picker is a month grid of
  rounded-square days with a tappable title for jumping years; the time picker has hour and
  minute steppers (minutes in steps of five) plus quick times 07.00, 09.00, 12.00, 17.00 and
  20.00. Screen readers adjust the steppers with swipe up/down.
- **Dialogs**: an icon tile (red for destructive actions), title, text, and two buttons of equal
  width: outlined cancel and filled confirm.
- **Toast**: replaces snackbars. A light card with a status-coloured edge and icon tile at the
  top of the screen (never under the keyboard, navigation bar or add button), optional action
  such as "Batalkan", swipe up to dismiss.
- **Loading**: three Plum dots pulsing in turn.
- **PIN pad**: rounded-square keys, not the round keys of a system lock screen.
- **Empty state**: illustration tile, title, one sentence, one primary action.
- **Detail rows**: long-press copies the value (handy for a customer number in the notes).

## Accessibility (WCAG AA)

- Every text/background pair the kit draws is checked at 4.5:1 or more, in both themes
  (`test/ui/palette_contrast_test.dart`).
- Status dots use the bright shades; status text uses darker (light mode) or lighter (dark mode)
  shades on a tinted chip to reach 4.5:1.
- Swipe backgrounds use `#067647` (paid) and `#B42318` (delete) behind white icons and text.
- Icon-only buttons always have a spoken label; switches and selected chips report their state.
- Minimum text size is 14sp. Touch targets are at least 48dp.

## Not the platform look

Being drawn by the app is not enough; controls must not *look* like Android (Material) or iOS
defaults either. So there is no ripple, no pill navigation indicator, no thumb-growing switch,
no extended FAB, no check-mark filter chips, no drag handle on sheets, no right-aligned text
buttons in dialogs, no dark snackbar, no spinning arc, no wheel or clock time picker, and no
round calendar-day or PIN keys. New components follow the same rule.

The only system UI left is what Android itself draws and the app cannot replace: the
fingerprint prompt, the file picker for backups, the share sheet and notifications.

## Deliberate differences from the original spec

- Notification actions stay "Sudah dibayar" and "Ingatkan besok" (no "View" action; tapping
  the notification opens the bill).
- Swipe left deletes (with confirmation) instead of archiving; one-off bills are archived
  automatically when paid.
- Service logos and payment-method fields are not included; cards show a category icon.
