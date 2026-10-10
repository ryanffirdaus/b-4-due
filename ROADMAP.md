# Roadmap

B4Due sengaja kecil: semua fitur harus tetap bekerja tanpa akun, tanpa server, dan tanpa
koneksi (internet hanya dipakai untuk kurs). Ide di bawah ini **di luar MVP** dan belum dibangun. Diskusikan dulu lewat
issue sebelum mengerjakannya.

## Kandidat berikutnya

- [ ] **Widget layar utama**: tagihan terdekat dan total bulan ini.
- [ ] **Backup terenkripsi dengan password**: file cadangan dienkripsi (mis. AES-GCM dengan
      kunci dari Argon2id/PBKDF2) supaya aman disimpan di cloud mana pun.
- [ ] **OCR foto tagihan**: membaca nominal dan tanggal dari foto struk/tagihan, sepenuhnya
      di perangkat (tanpa API cloud).
- [ ] **Rilis iOS** (butuh akun Apple Developer) dan uji di perangkat iOS.
- [ ] **Terjemahan tambahan** (Jawa, Sunda, dll.) lewat file ARB.

## Butuh desain ulang karena bertentangan dengan prinsip "tanpa server"

- [ ] **Sinkronisasi antar perangkat**: hanya jika bisa tanpa server pihak ketiga, misalnya
      lewat file di penyimpanan milik pengguna atau sinkronisasi lokal (Wi-Fi/Bluetooth).
- [ ] **Keluarga / multi-pengguna**: berbagi tagihan rumah tangga antar-HP.
- [ ] **Pengingat lewat Telegram/WhatsApp/email**: membutuhkan izin internet atau bot di
      server, sehingga kemungkinan tidak akan masuk aplikasi inti.

## Sudah ada (MVP)

CRUD tagihan dengan pengulangan, pengingat otomatis dengan aksi notifikasi, beranda dan
riwayat, template Indonesia, cadangan JSON/CSV dan Auto Backup, kunci aplikasi, cadangan
lewat kalender, panduan baterai per merek, mata uang asing dengan kurs otomatis, kalender
tagihan, dan statistik pengeluaran.

---

**English:** out-of-scope ideas, not yet built: home-screen widget, password-encrypted
backups, on-device OCR of bills, an iOS release, more translations.
Device sync, family sharing and Telegram/WhatsApp/email reminders conflict with the "no
server, offline-first" principle and need a different design first.
