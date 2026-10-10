# SQLite amalgamation

- Version: 3.53.4 (`sqlite-amalgamation-3530400.zip`, released 2026-07-24)
- Source: https://sqlite.org/2026/sqlite-amalgamation-3530400.zip
- SHA3-256 of the zip: `628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e`
- License: public domain (https://sqlite.org/copyright.html)

`package:sqlite3` compiles this file in its build hook for Android (see
`hooks.user_defines` in `pubspec.yaml`), so release APKs contain no prebuilt
binaries downloaded at build time. To upgrade, replace `sqlite3.c` and
`sqlite3.h` with a newer amalgamation and update this file. Prefer a release
that has been out for a few weeks.
