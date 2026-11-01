# Catatan migrasi Flutter: Users -> Siswa

## Isi paket

Salin isi folder `lib/` ke folder `lib/` project yang ada. Backend tidak berubah.

- `services/api_client.dart`: HTTP terpusat, Bearer token, timeout, HTTP 204, dan `ApiException`.
- `services/auth_service.dart` + `core/app_session.dart`: login, validasi `/auth/me`, logout, dan penanganan sesi.
- `models/`: `Siswa`, `AuthUser`, nilai dropdown, dan metadata pagination.
- `pages/data_page.dart`: daftar, pencarian debounce, filter, pagination, detail, edit, dan hapus siswa.
- `pages/siswa_form_page.dart`: form tambah/edit siswa.
- `pages/home_input.dart`: Input Siswa dan petunjuk Input Admin di luar endpoint register.

`services/user_service.dart` hanya menjadi shim ekspor `SiswaService` untuk membantu transisi import; endpoint `/users` tidak lagi digunakan.

## Menjalankan

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Flutter Web di browser pada komputer yang sama dengan backend:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000/api
```

HP fisik: gunakan alamat IPv4 LAN laptop, misalnya `http://192.168.1.10:3000/api` (ganti dengan alamat laptop yang sebenarnya), dan pastikan HP/laptop berada di jaringan yang sama serta firewall mengizinkan port backend.

Untuk Web, set `CORS_ORIGIN` pada backend ke origin Flutter Web yang benar. Ini konfigurasi backend yang sudah ada; jangan menambah endpoint atau mengubah kontrak API.

## HTTP cleartext hanya untuk Android debug

Karena file `android/` tidak disertakan saat audit, jangan mengganti manifest project secara keseluruhan. Untuk debug lokal saja, pastikan manifest debug (`android/app/src/debug/AndroidManifest.xml`) berisi elemen berikut di dalam `<manifest>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:usesCleartextTraffic="true" />
</manifest>
```

Jika file tersebut sudah punya elemen `<application>`, tambahkan atribut ke elemen yang ada, jangan membuat dua elemen application. Jangan menaruh izin cleartext ini di manifest release. Build produksi wajib HTTPS.

iOS bukan target dalam migrasi ini. Jika nanti ditambahkan, pengecualian ATS lokal harus dibatasi untuk development.

## Catatan penyimpanan Web

`flutter_secure_storage` dipertahankan sesuai ketentuan. Di Web, browser perlu secure context; localhost biasanya didukung untuk development, sedangkan deployment harus HTTPS. Uji target browser yang digunakan sebelum rilis. Token tidak ditulis ke log dan password tidak disimpan.

## Batasan Input Admin

Tombol Input Admin hanya menjelaskan mekanisme pembuatan akun di luar aplikasi (misalnya database/terminal). Tidak ada registrasi publik dan aplikasi tidak memanggil `/auth/register`.
