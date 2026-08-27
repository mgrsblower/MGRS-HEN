# MGRS-HEN

Private, static PS4 WebKit HEN host untuk deployment sendiri di Vercel. Halaman mendeteksi firmware dari user-agent PS4, memilih chain Lapse atau Poops secara otomatis, menyimpan runtime melalui Application Cache, lalu memuat payload dari origin yang sama.

## Firmware yang tersedia

| Firmware | Chain | Patch |
|---|---|---|
| 11.00 | Lapse | `patches/1100.bin` |
| 11.50 | Lapse | `patches/1150.bin` |
| 12.00 | Lapse | `patches/1200.bin` |
| 12.02 | Lapse | alias 12.00, `patches/1200.bin` |
| 12.50 | Poops | `patches/1250.bin` |
| 12.52 | Poops | alias 12.50, `patches/1250.bin` |
| 13.00 | Poops | `patches/1300.bin` |

Firmware 12.03-12.49 dan firmware tanpa tabel offset yang tepat akan dihentikan sebelum chain dijalankan. Alias 11.52 dari repository pembanding sengaja tidak disertakan karena ditandai belum diuji pada hardware.

## Deploy ke Vercel

1. Buat repository GitHub kosong milikmu, lalu push isi folder ini.
2. Di Vercel, pilih **Add New Project** dan import repository tersebut.
3. Pilih framework **Other**.
4. Biarkan Root Directory di root repository.
5. Build Command, Install Command, dan Output Directory tidak perlu diisi.
6. Jalankan deployment.
7. Verifikasi header manifest:

   ```powershell
   curl.exe -I https://DOMAIN-KAMU.vercel.app/cache.appcache
   ```

   Respons harus mengandung `Content-Type: text/cache-manifest` dan `Cache-Control: no-cache`.

Konfigurasi routing dan header berada di `vercel.json`. Tidak ada backend, database, analytics, CDN script, atau runtime dependency eksternal.

## Preview lokal

Untuk memeriksa halaman dan aset secara lokal:

```powershell
py -m http.server 8080 --directory src
```

Kemudian buka `http://127.0.0.1:8080/`. Server Python cukup untuk preview visual dan pemeriksaan HTTP. Kontrak MIME Application Cache yang dipakai PS4 divalidasi melalui konfigurasi Vercel dan harus diperiksa kembali pada URL deployment.

## Verifikasi integritas

Jalankan dari root repository:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/update-integrity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verify-project.ps1
```

`update-integrity.ps1` melakukan pekerjaan lokal dan deterministik:

- Menghitung SHA-256 semua aset deployment.
- Menulis `checksums.sha256`.
- Menghasilkan build ID dari ledger yang sudah diurutkan.
- Menulis `src/cache.appcache` tanpa BOM dan tanpa request jaringan.

`verify-project.ps1` memeriksa:

- Hash tetap untuk chain, offset, kernel patch, dan payload.
- Tujuh firmware yang diizinkan tanpa alias 11.52.
- Branding MGRS-HEN tanpa logo atau teks host asal.
- Semua checksum dan Application Cache entry.
- Kontrak MIME/cache di `vercel.json`.

Payload yang dibundel saat repository dibuat:

```text
SHA-256  c6329401d1810e16c84e6474ac30977dbdc951987c10cdb559370de7d59db0b0
Size     290016 bytes
```

Jangan memperbarui chain, patch, offset, atau payload secara otomatis. Perubahan yang disengaja harus ditinjau, dibandingkan dengan sumber yang dipercaya, lalu hash pin di verifier diperbarui secara eksplisit.

## Cara kerja cache

Pada kunjungan pertama, PS4 mengunduh HTML, CSS, JavaScript, patch, dan payload yang tercantum dalam `cache.appcache`. Setelah status cache selesai, halaman meminta tombol X atau tap sebelum melanjutkan. Perubahan aset menghasilkan build ID baru sehingga browser PS4 mengambil cache yang baru.

Application Cache sudah usang di browser modern, tetapi dipertahankan karena targetnya adalah WebKit PS4. Menghapus data browser PS4 juga menghapus salinan offline.

## Batas QA

QA desktop dapat membuktikan bahwa:

- Struktur repository, hash, dan manifest konsisten.
- Semua aset dapat dilayani melalui HTTP.
- Halaman root dan entry page dapat dirender di beberapa viewport.
- Firmware detector dan tabel offset tersedia di source.

QA desktop tidak dapat membuktikan keberhasilan primitive WebKit, kernel read/write, patch kernel, atau eksekusi HEN. Itu memerlukan pengujian langsung pada PS4 milik sendiri dengan firmware yang cocok.

## Peringatan

- Kernel exploit dapat gagal, freeze, kernel panic, atau mematikan konsol secara mendadak.
- HEN tidak permanen dan umumnya perlu dijalankan kembali setelah reboot penuh.
- Jangan memaksa chain melalui query parameter pada firmware yang tidak cocok.
- Jangan memperbarui firmware PS4 jika ingin mempertahankan kompatibilitas exploit.
- Gunakan hanya pada hardware milik sendiri atau hardware yang kamu berwenang untuk uji.

## Provenance dan lisensi

Baseline runtime diambil dari commit `56a5d7697234246b9739e6aaafb0c70adae66a57` pada [`lutfailham96/PS4-JB-WebKit`](https://github.com/lutfailham96/PS4-JB-WebKit). Chain, patch, offset setelah penghapusan alias 11.52, dan payload juga dibandingkan dengan salinan yang disajikan `raw-game.com/zrm` pada 2026-08-28.

Repository sumber menyertakan lisensi MIT dengan placeholder pemegang hak cipta; salinannya dipertahankan dalam `LICENSE.md`. Payload dan komponen pihak ketiga dapat memiliki ketentuan distribusi masing-masing. Periksa hak distribusinya sebelum membuat deployment publik.
