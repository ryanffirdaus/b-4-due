#!/usr/bin/env bash
# Fails if an APK requests any permission not listed below (INTERNET is
# allowed only for downloading exchange rates; see PRIVACY.md).
#
#   tool/check_apk_permissions.sh build/app/outputs/flutter-apk/*.apk
#
# Anyone can run the same check on a downloaded release:
#   aapt2 dump permissions b4due-*.apk
set -euo pipefail

ALLOWED=(
  android.permission.INTERNET                    # daily exchange rates only
  android.permission.POST_NOTIFICATIONS          # reminders
  android.permission.RECEIVE_BOOT_COMPLETED      # restore reminders after reboot
  android.permission.VIBRATE
  android.permission.SCHEDULE_EXACT_ALARM        # Android 12 only (maxSdkVersion 32)
  android.permission.USE_EXACT_ALARM             # on-time reminders, Android 13+
  android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
  android.permission.READ_CALENDAR               # opt-in "Tambahkan ke Kalender"
  android.permission.WRITE_CALENDAR
  android.permission.USE_BIOMETRIC               # optional app lock
  android.permission.USE_FINGERPRINT
  android.permission.WAKE_LOCK                   # WorkManager background sync
  android.permission.FOREGROUND_SERVICE          # declared by WorkManager
  android.permission.FOREGROUND_SERVICE_SHORT_SERVICE
  io.github.ryanffirdaus.b4due.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
)
FORBIDDEN_REGEX='android\.permission\.(ACCESS_NETWORK_STATE|ACCESS_WIFI_STATE|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE|READ_MEDIA_.*|READ_CONTACTS|ACCESS_.*LOCATION|CAMERA|RECORD_AUDIO)'

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <apk>..." >&2
  exit 2
fi

AAPT2="${AAPT2:-$(command -v aapt2 || ls "${ANDROID_HOME:-$ANDROID_SDK_ROOT}"/build-tools/*/aapt2 2>/dev/null | sort -V | tail -1)}"
[[ -x "$AAPT2" ]] || { echo "aapt2 not found; set AAPT2" >&2; exit 2; }

status=0
for apk in "$@"; do
  perms=$("$AAPT2" dump permissions "$apk" | sed -n "s/^uses-permission: name='\([^']*\)'.*/\1/p" | sort -u)
  echo "== $apk"
  echo "$perms" | sed 's/^/   /'
  if echo "$perms" | grep -Eq "^${FORBIDDEN_REGEX}$"; then
    echo "ERROR: forbidden permission in $apk:" >&2
    echo "$perms" | grep -E "^${FORBIDDEN_REGEX}$" >&2
    status=1
  fi
  for perm in $perms; do
    if ! printf '%s\n' "${ALLOWED[@]}" | grep -qx "$perm"; then
      echo "ERROR: unexpected permission $perm in $apk (update the allowlist and PRIVACY.md if intended)" >&2
      status=1
    fi
  done
done
[[ $status -eq 0 ]] && echo "OK: only allowlisted permissions."
exit $status
