# Berkontribusi ke B4Due

Terima kasih sudah mau membantu! Kontribusi apa pun diterima: laporan bug, terjemahan,
perbaikan panduan per merek HP, atau kode.

## Prinsip yang tidak bisa ditawar

1. **Internet hanya untuk kurs.** Satu-satunya akses jaringan adalah mengunduh kurs dari
   `api.frankfurter.dev`, tanpa data pengguna. Tidak ada analytics, pelacak, atau layanan
   Google Play. Fitur baru harus tetap bekerja tanpa koneksi.
2. **Tanpa akun dan tanpa server.** Data hanya ada di HP pengguna.
3. **Mudah untuk orang awam.** Teks UI berbahasa Indonesia yang sederhana. Tombol minimal
   48dp, dan layar tetap rapi dengan ukuran huruf sistem yang besar.

## Melaporkan bug

Sertakan merek dan tipe HP, versi Android, versi B4Due, dan langkah untuk mengulang bugnya.
Untuk masalah notifikasi, sebutkan juga pengaturan baterai yang sudah dicoba. **Jangan**
melampirkan file cadangan asli; datanya bersifat pribadi.

## Menyiapkan lingkungan

```sh
fvm install && fvm flutter pub get
dart run build_runner build      # kode Drift
fvm flutter test
```

Perlu JDK 17 dan Android SDK 36. Lihat bagian *Untuk pengembang* di [README](README.md).

## Alur kerja

1. **Setiap perubahan dimulai dari issue.** Buka issue (bug atau usulan fitur) dan catat nomornya.
2. Buat branch dari `main`, misalnya `feat/12-yearly-recurrence`, lalu kirim pull request kecil
   yang fokus pada satu hal. Tulis `Closes #12` di deskripsi PR.
3. Setiap commit memakai [Conventional Commits](https://www.conventionalcommits.org/) **dengan
   scope dan nomor issue**:

   ```
   feat(bills): add yearly recurrence (#12)
   fix(reminders): reschedule after a time zone change (#15)
   ```

   Tipe yang dipakai: `feat`, `fix`, `perf`, `refactor`, `style`, `test`, `docs`, `build`, `ci`,
   `chore`, `revert`. Perubahan yang merusak kompatibilitas diberi `!` (`feat(backup)!: ...`)
   dan paragraf `BREAKING CHANGE:` di badan commit. CI menolak commit yang tidak sesuai; cek
   sendiri dengan `tool/check_commits.sh origin/main..HEAD`.
4. Kode, nama variabel, dan komentar dalam **bahasa Inggris**; teks UI lewat file ARB.
5. Sebelum PR: `dart format lib test integration_test`, `flutter analyze --fatal-infos`, dan `flutter test`.

## Rilis dan versi

B4Due memakai [Semantic Versioning](https://semver.org/) yang diatur otomatis oleh
[release-please](https://github.com/googleapis/release-please):

- Setiap push ke `main` membuat atau memperbarui **PR rilis** yang menaikkan `version:` di
  `pubspec.yaml` (nomor build Android ikut naik) dan menulis `CHANGELOG.md` dari pesan commit.
- `fix` menaikkan PATCH, `feat` menaikkan MINOR, dan `!`/`BREAKING CHANGE` menaikkan MAJOR
  (selama masih 0.x, perubahan besar menaikkan MINOR).
- Saat PR rilis di-merge, tag `vX.Y.Z` dan GitHub Release dibuat, lalu workflow
  [Release](.github/workflows/release.yml) membangun APK bertanda tangan dan melampirkannya.
- Jangan mengubah versi atau CHANGELOG secara manual.

## Panduan teknis

- **Teks UI** ditambahkan di `lib/l10n/app_id.arb` dan `app_en.arb`. Tes memastikan
  keduanya punya kunci yang sama.
- **Perubahan tabel**: ubah `lib/core/database/tables.dart`, naikkan `schemaVersion`, jalankan
  `dart run build_runner build` dan `dart run drift_dev make-migrations`, tulis langkah
  migrasi di `app_database.dart`, lalu tambahkan tes data di
  `test/core/database/migrations`. Jangan pernah mengubah dump skema lama di `drift_schemas/`.
- **Logika penjadwalan** ada di `planNotifications` (fungsi murni). Setiap aturan baru wajib
  disertai tes di `test/features/reminders/domain/reminder_planner_test.dart`.
- **Format cadangan** didokumentasikan di [docs/BACKUP_FORMAT.md](docs/BACKUP_FORMAT.md).
  Perubahan yang tidak kompatibel wajib menaikkan `version`.
- **Golden test** dibandingkan ketat hanya di Linux. Perbarui dengan
  `flutter test --update-goldens` di Linux (atau WSL), lalu periksa gambarnya sebelum commit.
- **Panduan baterai per merek**: perbaikan langkah sangat membantu. Teksnya ada di kunci
  `guide*` pada file ARB, dan halaman *Pengaturan baterai* menampilkannya.

---

**English:** contributions are welcome. Non-negotiables: the network is used only for anonymous
exchange-rate downloads (no analytics or trackers, everything works offline), no accounts or servers, and plain Indonesian UI text that works at large font
sizes. Start every change from an issue; commit subjects use
Conventional Commits with a scope and the issue number, e.g. `feat(bills): add yearly
recurrence (#12)` (checked by CI). Versions are semver and released by release-please from
those commits; never edit the version or CHANGELOG by hand. Keep code and comments in English, put UI strings in the ARB
files, and run format, analyze and tests before opening a PR. Schema changes need a migration
step plus a migration test; scheduling changes need planner tests.
