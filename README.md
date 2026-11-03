# School Admin — Login App

Aplikasi Flutter untuk admin sekolah: login aman berbasis token dan manajemen data siswa (CRUD) yang terhubung ke REST API.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.13.5-0175C2?logo=dart&logoColor=white)
![Platform](<https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey>)

## Daftar Isi

- [Fitur](#fitur)
- [Tech Stack](#tech-stack)
- [Struktur Project](#struktur-project)
- [Prasyarat](#prasyarat)
- [Instalasi](#instalasi)
- [Konfigurasi API](#konfigurasi-api)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Kontrak API](#kontrak-api)
- [Keamanan](#keamanan)
- [Testing](#testing)
- [Build Rilis](#build-rilis)
- [Troubleshooting](#troubleshooting)

## Fitur

**Autentikasi**

- Login dengan username atau email dan password
- Token disimpan aman dengan `flutter_secure_storage` (password tidak pernah disimpan)
- Pemulihan sesi otomatis saat aplikasi dibuka (validasi token lewat `/auth/me`)
- Penanganan sesi habis: HTTP 401 otomatis menghapus token dan mengarahkan ke halaman login
- Route guard: halaman dashboard tidak bisa diakses tanpa login
- Tidak ada registrasi publik, akun admin dibuat di luar aplikasi (lewat database atau terminal backend)

**Manajemen Data Siswa**

- Daftar siswa dengan pagination
- Pencarian berdasarkan nama atau NIPD (dengan debounce)
- Filter berdasarkan kelas, jurusan, dan jenis kelamin
- Detail, tambah, edit, dan hapus siswa (dengan konfirmasi)
- Validasi form di sisi klien, plus penampilan error validasi per-field dari server

**Lapisan jaringan**

- Satu klien HTTP terpusat (`ApiClient`) dengan Bearer token otomatis
- Timeout 12 detik, penanganan HTTP 204, dan `ApiException` terstruktur
- Pesan error berbahasa Indonesia untuk kasus 401, 409, 422, 429, timeout, dan gagal koneksi

## Tech Stack

| Komponen          | Teknologi                                                                                |
| ----------------- | ---------------------------------------------------------------------------------------- |
| Framework         | Flutter (Material Design)                                                                |
| Bahasa            | Dart `^3.13.5`                                                                         |
| HTTP client       | [`http`](https://pub.dev/packages/http) `^1.6.0`                                      |
| Penyimpanan token | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) `^11.2.0` |
| State sesi        | `ChangeNotifier` (`AppSession`)                                                      |
| Navigasi          | Named routes + `onGenerateRoute`                                                       |
| Lint              | `flutter_lints` `^6.0.0`                                                             |

> Backend **tidak termasuk** di repository ini. Aplikasi ini hanya client yang mengonsumsi REST API terpisah.

## Struktur Project

```
lib/
├── main.dart                  # Entry point, routing, dan route guard
├── core/
│   ├── app_navigator.dart     # Global navigator key
│   └── app_session.dart       # State sesi (login, logout, restore, 401)
├── models/
│   ├── auth_user.dart         # Model admin
│   ├── siswa.dart             # Model siswa + opsi dropdown
│   └── paginated_result.dart  # Metadata pagination
├── services/
│   ├── api_client.dart        # Klien HTTP terpusat + ApiException
│   ├── auth_service.dart      # Login, /auth/me, logout
│   ├── siswa_service.dart     # CRUD siswa
│   └── user_service.dart      # Shim ekspor SiswaService (kompatibilitas)
└── pages/
    ├── login_page.dart        # Halaman login
    ├── home_page.dart         # Dashboard admin
    ├── data_page.dart         # Daftar, cari, filter, pagination
    ├── siswa_detail_page.dart # Detail siswa
    ├── siswa_form_page.dart   # Form tambah/edit siswa
    └── home_input.dart        # Halaman Input Siswa / petunjuk Input Admin
```

Folder platform: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`.

## Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) dengan Dart `^3.13.5`
- Backend REST API yang berjalan (lihat [Kontrak API](#kontrak-api))
- Untuk Android: Android Studio dan emulator atau perangkat fisik
- Untuk Web: Google Chrome

Cek lingkungan Flutter:

```bash
flutter doctor
```

## Instalasi

```bash
# 1. Clone repository
git clone https://github.com/wann-a08/login_app.git
cd login_app

# 2. Install dependency
flutter pub get
```

## Konfigurasi API

Alamat API diatur lewat `--dart-define` saat menjalankan atau membangun aplikasi. Nilai default: `http://127.0.0.1:3000/api`.

| Target                                               | Nilai `API_BASE_URL`                                                          |
| ---------------------------------------------------- | ------------------------------------------------------------------------------- |
| Android emulator                                     | `http://10.0.2.2:3000/api`                                                    |
| Flutter Web / Desktop (satu komputer dengan backend) | `http://127.0.0.1:3000/api`                                                   |
| HP fisik                                             | `http://<IPv4-LAN-laptop>:3000/api` (contoh `http://192.168.1.10:3000/api`) |
| Produksi                                             | `https://domain-anda.com/api` (wajib HTTPS)                                   |

Untuk HP fisik, pastikan HP dan laptop berada di jaringan yang sama dan firewall mengizinkan port backend.

## Menjalankan Aplikasi

```bash
# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api

# Web (Chrome)
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000/api

# Windows / macOS / Linux
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:3000/api
```

**Untuk Flutter Web:** set `CORS_ORIGIN` di backend ke origin Flutter Web yang dipakai, kalau tidak browser akan memblokir request.

## Kontrak API

Semua endpoint berada di bawah `API_BASE_URL` dan memakai JSON. Endpoint selain login memerlukan header `Authorization: Bearer <token>`.

| Method     | Endpoint        | Keterangan                                                                                                                                                           |
| ---------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST`   | `/auth/login` | Body: `identifier`, `password`. Respons: `data.token` dan `data.user`                                                                                        |
| `GET`    | `/auth/me`    | Validasi token dan ambil data admin                                                                                                                                  |
| `GET`    | `/siswa`      | Query: `page`, `limit`, `search`, `kelas`, `jurusan`, `jenis_kelamin`. Respons: `data[]` dan `meta` (`page`, `limit`, `total`, `totalPages`) |
| `GET`    | `/siswa/:id`  | Detail siswa                                                                                                                                                         |
| `POST`   | `/siswa`      | Tambah siswa                                                                                                                                                         |
| `PUT`    | `/siswa/:id`  | Ubah siswa                                                                                                                                                           |
| `DELETE` | `/siswa/:id`  | Hapus siswa                                                                                                                                                          |

**Format data siswa**

| Field             | Tipe   | Nilai / batasan                             |
| ----------------- | ------ | ------------------------------------------- |
| `nipd`          | string | Wajib, maks. 50 karakter                    |
| `nama_lengkap`  | string | Wajib, maks. 50 karakter                    |
| `jenis_kelamin` | string | `L` atau `P`                            |
| `kelas`         | string | `10`, `11`, `12`                      |
| `jurusan`       | string | `RPL`, `DKV`, `BIDI`, `TKJ`, `AK` |
| `alamat`        | string | Opsional, maks. 50 karakter                 |

**Format error validasi (HTTP 422)**

```json
{
  "message": "Validasi gagal",
  "errors": [{ "field": "nipd", "message": "NIPD sudah digunakan" }]
}
```

## Keamanan

- Token disimpan di secure storage dan tidak ditulis ke log.
- Password tidak disimpan di perangkat.
- **HTTP cleartext hanya untuk development lokal.** Pastikan `android:usesCleartextTraffic="true"` tidak ikut ke build rilis. Letakkan di manifest debug (`android/app/src/debug/AndroidManifest.xml`), bukan di manifest utama.
- Build produksi wajib memakai HTTPS.
- Di Web, `flutter_secure_storage` membutuhkan secure context. `localhost` umumnya didukung untuk development, tetapi deployment harus HTTPS.
- Pembuatan akun admin dilakukan di luar aplikasi (database atau terminal backend). Aplikasi tidak memanggil `/auth/register`.

## Testing

```bash
flutter analyze
flutter test
```

## Build Rilis

```bash
# Android APK
flutter build apk --release --dart-define=API_BASE_URL=https://domain-anda.com/api

# Web
flutter build web --release --dart-define=API_BASE_URL=https://domain-anda.com/api
```

## Troubleshooting

| Masalah                                               | Solusi                                                                         |
| ----------------------------------------------------- | ------------------------------------------------------------------------------ |
| "Tidak dapat terhubung ke server" di emulator Android | Pakai `10.0.2.2`, bukan `127.0.0.1` atau `localhost`                     |
| Gagal konek dari HP fisik                             | Pakai IP LAN laptop, satu jaringan Wi-Fi, dan izinkan port backend di firewall |
| Request diblokir di Flutter Web                       | Set `CORS_ORIGIN` di backend sesuai origin Flutter Web                       |
| Login berhasil lalu langsung kembali ke halaman login | Token ditolak (401). Cek `JWT` secret dan masa berlaku token di backend      |
| Error cleartext HTTP di Android                       | Pastikan `usesCleartextTraffic` aktif untuk debug saja                       |

## Identitas Developer

1. Muhammad Ihwan Utomo (242510068) Kelas 12 RPL SMK Bina Putra Mandiri
2. Abdul Syahril Pratama (242510055) Kelas 12 RPL SMK Bina Putra Mandiri
