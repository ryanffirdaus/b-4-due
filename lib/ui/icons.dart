import 'package:flutter/widgets.dart';

/// The subset of [Remix Icon](https://remixicon.com) v4.8.0 used by the app.
///
/// v4.8.0 is the last release under the Apache License 2.0 (later releases
/// moved to a custom licence), so the font is vendored rather than taken
/// from pub.dev: assets/fonts/RemixIcon.ttf, licence alongside it. Release
/// builds tree-shake the font down to these glyphs because every icon is a
/// `const` [IconData].
///
/// To add one, look up its codepoint in `fonts/remixicon.glyph.json` at the
/// v4.8.0 tag of github.com/Remix-Design/RemixIcon.
abstract final class RemixIcons {
  static const _family = 'RemixIcon';

  /// `add-line`
  static const addLine = IconData(0xea13, fontFamily: _family);

  /// `alarm-line`
  static const alarmLine = IconData(0xea1b, fontFamily: _family);

  /// `apps-2-line`
  static const apps2Line = IconData(0xea42, fontFamily: _family);

  /// `arrow-down-s-line`
  static const arrowDownSLine = IconData(0xea4e, fontFamily: _family);

  /// `arrow-go-back-line`
  static const arrowGoBackLine = IconData(0xea58, fontFamily: _family);

  /// `arrow-left-line`
  static const arrowLeftLine = IconData(0xea60, fontFamily: _family);

  /// `arrow-left-s-line`
  static const arrowLeftSLine = IconData(0xea64, fontFamily: _family);

  /// `arrow-right-s-line`
  static const arrowRightSLine = IconData(0xea6e, fontFamily: _family);

  /// `bank-card-line`
  static const bankCardLine = IconData(0xea92, fontFamily: _family);

  /// `battery-2-charge-line`
  static const battery2ChargeLine = IconData(0xeaaa, fontFamily: _family);

  /// `bill-fill`
  static const billFill = IconData(0xeac1, fontFamily: _family);

  /// `bill-line`
  static const billLine = IconData(0xeac2, fontFamily: _family);

  /// `calendar-2-fill`
  static const calendar2Fill = IconData(0xeb20, fontFamily: _family);

  /// `calendar-2-line`
  static const calendar2Line = IconData(0xeb21, fontFamily: _family);

  /// `calendar-check-line`
  static const calendarCheckLine = IconData(0xeb23, fontFamily: _family);

  /// `calendar-close-line`
  static const calendarCloseLine = IconData(0xf38e, fontFamily: _family);

  /// `calendar-event-line`
  static const calendarEventLine = IconData(0xeb25, fontFamily: _family);

  /// `calendar-todo-line`
  static const calendarTodoLine = IconData(0xeb29, fontFamily: _family);

  /// `check-line`
  static const checkLine = IconData(0xeb7b, fontFamily: _family);

  /// `checkbox-circle-fill`
  static const checkboxCircleFill = IconData(0xeb80, fontFamily: _family);

  /// `checkbox-circle-line`
  static const checkboxCircleLine = IconData(0xeb81, fontFamily: _family);

  /// `checkbox-multiple-line`
  static const checkboxMultipleLine = IconData(0xeb89, fontFamily: _family);

  /// `clipboard-line`
  static const clipboardLine = IconData(0xeb91, fontFamily: _family);

  /// `close-line`
  static const closeLine = IconData(0xeb99, fontFamily: _family);

  /// `delete-back-2-line`
  static const deleteBack2Line = IconData(0xec1a, fontFamily: _family);

  /// `delete-bin-6-line`
  static const deleteBin6Line = IconData(0xec26, fontFamily: _family);

  /// `download-2-line`
  static const download2Line = IconData(0xec54, fontFamily: _family);

  /// `drop-line`
  static const dropLine = IconData(0xec6a, fontFamily: _family);

  /// `equalizer-2-line`
  static const equalizer2Line = IconData(0xf404, fontFamily: _family);

  /// `exchange-dollar-line`
  static const exchangeDollarLine = IconData(0xeca9, fontFamily: _family);

  /// `error-warning-line`
  static const errorWarningLine = IconData(0xeca1, fontFamily: _family);

  /// `external-link-line`
  static const externalLinkLine = IconData(0xecaf, fontFamily: _family);

  /// `file-copy-line`
  static const fileCopyLine = IconData(0xecd5, fontFamily: _family);

  /// `file-excel-2-line`
  static const fileExcel2Line = IconData(0xecdd, fontFamily: _family);

  /// `file-list-3-line`
  static const fileList3Line = IconData(0xecef, fontFamily: _family);

  /// `fingerprint-line`
  static const fingerprintLine = IconData(0xed31, fontFamily: _family);

  /// `flashlight-line`
  static const flashlightLine = IconData(0xed3d, fontFamily: _family);

  /// `graduation-cap-line`
  static const graduationCapLine = IconData(0xf333, fontFamily: _family);

  /// `hand-coin-line`
  static const handCoinLine = IconData(0xedf1, fontFamily: _family);

  /// `history-line`
  static const historyLine = IconData(0xee17, fontFamily: _family);

  /// `home-4-line`
  static const home4Line = IconData(0xee1d, fontFamily: _family);

  /// `home-5-fill`
  static const home5Fill = IconData(0xee1e, fontFamily: _family);

  /// `home-5-line`
  static const home5Line = IconData(0xee1f, fontFamily: _family);

  /// `information-line`
  static const informationLine = IconData(0xee59, fontFamily: _family);

  /// `key-2-line`
  static const key2Line = IconData(0xee6f, fontFamily: _family);

  /// `lock-2-line`
  static const lock2Line = IconData(0xeecc, fontFamily: _family);

  /// `motorbike-line`
  static const motorbikeLine = IconData(0xef7b, fontFamily: _family);

  /// `notification-3-line`
  static const notification3Line = IconData(0xef94, fontFamily: _family);

  /// `pencil-line`
  static const pencilLine = IconData(0xefe0, fontFamily: _family);

  /// `pie-chart-2-fill`
  static const pieChart2Fill = IconData(0xeff5, fontFamily: _family);

  /// `pie-chart-2-line`
  static const pieChart2Line = IconData(0xeff6, fontFamily: _family);

  /// `play-circle-line`
  static const playCircleLine = IconData(0xf009, fontFamily: _family);

  /// `refresh-line`
  static const refreshLine = IconData(0xf064, fontFamily: _family);

  /// `restart-line`
  static const restartLine = IconData(0xf080, fontFamily: _family);

  /// `save-3-line`
  static const save3Line = IconData(0xf0b1, fontFamily: _family);

  /// `scissors-cut-line`
  static const scissorsCutLine = IconData(0xf0c1, fontFamily: _family);

  /// `search-line`
  static const searchLine = IconData(0xf0d1, fontFamily: _family);

  /// `settings-3-fill`
  static const settings3Fill = IconData(0xf0e5, fontFamily: _family);

  /// `settings-3-line`
  static const settings3Line = IconData(0xf0e6, fontFamily: _family);

  /// `share-forward-line`
  static const shareForwardLine = IconData(0xf0fd, fontFamily: _family);

  /// `shield-check-line`
  static const shieldCheckLine = IconData(0xf100, fontFamily: _family);

  /// `shield-cross-line`
  static const shieldCrossLine = IconData(0xf102, fontFamily: _family);

  /// `shield-user-line`
  static const shieldUserLine = IconData(0xf10c, fontFamily: _family);

  /// `smartphone-line`
  static const smartphoneLine = IconData(0xf15a, fontFamily: _family);

  /// `time-line`
  static const timeLine = IconData(0xf20f, fontFamily: _family);

  /// `wifi-line`
  static const wifiLine = IconData(0xf2c0, fontFamily: _family);
}
