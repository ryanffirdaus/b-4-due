# Kebijakan Privasi B4Due

**Singkatnya: data Anda tidak pernah keluar dari HP Anda. Internet hanya dipakai untuk mengunduh kurs mata uang.**

- B4Due tidak punya akun, server, analytics, iklan, atau pelacak.
- Izin internet (`android.permission.INTERNET`) dipakai **hanya** untuk satu permintaan:
  `GET https://api.frankfurter.dev/v1/latest`, yaitu daftar kurs referensi Bank Sentral Eropa.
  Permintaan ini tidak membawa data apa pun tentang Anda: tanpa akun, tanpa ID perangkat, tanpa
  nama atau nominal tagihan, dan tanpa cookie. Yang terlihat oleh server itu hanyalah alamat IP
  dan bahwa ada aplikasi "B4Due" yang meminta kurs.
- Kurs diperbarui paling sering setiap 12 jam (saat aplikasi dibuka atau lewat pengecekan latar
  belakang). Tanpa koneksi, kurs terakhir tetap dipakai dan pengingat tetap berjalan normal.
- Setiap rilis diperiksa otomatis oleh CI
  ([`tool/check_apk_permissions.sh`](tool/check_apk_permissions.sh)) agar tidak ada izin lain di
  luar daftar di bawah. Anda bisa memeriksanya sendiri dengan `aapt2 dump permissions b4due-*.apk`.
- Tagihan, riwayat pembayaran, dan pengaturan disimpan di database SQLite di penyimpanan
  pribadi aplikasi.
- Data hanya keluar dari HP jika **Anda sendiri** yang memindahkannya:
  - **Android Auto Backup** ke Google Drive Anda (fitur sistem Android, bisa dimatikan di Setelan HP);
  - file cadangan JSON atau CSV yang Anda bagikan atau simpan sendiri;
  - event kalender jika Anda menekan "Tambahkan ke Kalender". Event masuk ke kalender HP, yang
    mungkin disinkronkan oleh akun kalender Anda.
- Tombol "Buka tautan pembayaran" membuka alamat yang Anda isi di browser HP Anda.
- PIN kunci aplikasi disimpan sebagai hash PBKDF2 dan tidak pernah ikut dalam file cadangan.

## Izin yang dipakai

| Izin | Untuk apa |
|---|---|
| Internet (`INTERNET`) | mengunduh kurs mata uang asing dari api.frankfurter.dev (tanpa data pribadi) |
| Notifikasi (`POST_NOTIFICATIONS`) | menampilkan pengingat |
| Alarm tepat waktu (`USE_EXACT_ALARM`, `SCHEDULE_EXACT_ALARM` di Android 12) | pengingat muncul tepat di jam yang dipilih |
| Mulai saat HP dinyalakan (`RECEIVE_BOOT_COMPLETED`) | menjadwalkan ulang pengingat setelah HP restart |
| `WAKE_LOCK`, `FOREGROUND_SERVICE*` | dipakai pustaka WorkManager untuk pengecekan cadangan di latar belakang |
| Abaikan optimasi baterai | menampilkan dialog sistem "izinkan berjalan di latar belakang" (hanya jika Anda menekannya) |
| Kalender (`READ_CALENDAR`, `WRITE_CALENDAR`) | hanya diminta saat Anda menekan "Tambahkan ke Kalender" |
| Biometrik | hanya jika Anda mengaktifkan kunci sidik jari/wajah |
| Getar | getaran notifikasi |

Tidak ada izin lokasi, kontak, kamera, mikrofon, atau penyimpanan. File cadangan disimpan dan
dibuka lewat pemilih berkas sistem.

---

# Privacy policy (English)

**In short: your data never leaves your phone.** B4Due has no account, server, analytics, ads
or trackers. The INTERNET permission is used for exactly one request: an anonymous
`GET https://api.frankfurter.dev/v1/latest` for European Central Bank reference exchange rates,
at most every 12 hours. It carries no account, device ID, bill names or amounts; the server
only sees your IP address. Without a connection the last rates are kept and reminders work
normally. CI checks every release against a permission allowlist. Data leaves the device only when you move it yourself: Android Auto Backup to your
own Google Drive, a backup/CSV file you share or save, or calendar events you choose to add.
The app-lock PIN is stored as a PBKDF2 hash and is never included in backups. The table above
lists every permission and why it is needed.
