# Mindeva — Your AI Companion for Emotional Wellness

Mindeva adalah aplikasi mobile asisten kesehatan mental modern dan premium yang dirancang khusus untuk Gen Z dan mahasiswa. Aplikasi ini membantu pengguna melacak mood harian, menulis jurnal refleksi, mendapatkan analisis emosional mendalam berbasis AI, latihan pernapasan, serta gamifikasi kebiasaan positif (streak, XP, lencana pencapaian).

---

## 🌟 Fitur Utama
1. **Premium Aesthetics**: Desain modern minimalis bernuansa calming (Lavender & Soft Blue) dengan sentuhan efek *glassmorphism* melayang dan animasi halus.
2. **Interactive Mood Tracker**: Pemilih emosi harian menggunakan emoji besar interaktif, pencatatan alasan, pencarian, dan visualisasi grafik mingguan/bulanan.
3. **AI Mood Analysis (Gemini API)**: Menganalisis tingkat stres (skala 1-5), sentimen, afirmasi positif harian, dan rekomendasi perawatan diri otomatis berdasarkan catatan mood & jurnal.
4. **Emotion Journal**: Penulisan jurnal harian dengan deteksi emosi otomatis dan *AI Tagging* tag otomatis.
5. **Emotion Calendar**: Visualisasi warna mood harian dalam kalender interaktif dan heatmap emosional.
6. **Gamified Streak & XP**: Tantangan beruntun (calm streak), pengumpulan XP mental, kenaikan level, dan pembukaan lencana prestasi (Badges).
7. **Latihan Pernapasan**: Panduan bernapas visual kotak/bulat interaktif dengan pengaturan waktu relaksasi (Inhale - Hold - Exhale).
8. **Mental Wellness Tips**: Dek artikel/tips terintegrasi untuk pertolongan pertama kecemasan dan self healing.

---

## 🏗️ Struktur Arsitektur (Clean Architecture)
Proyek ini diorganisasi dengan struktur bersih dan modular:
```text
lib/
├── core/            # Konfigurasi Tema (Light/Dark/Glassmorphism), Konstanta, & Toggle Firebase
├── models/          # Model data terstruktur (User, Mood, Journal, Achievement)
├── services/        # Layanan API (Google Gemini SDK, Local SharedPreferences)
├── repositories/    # Abstraksi repositori data (Dual-mode: Firebase Cloud vs Local Offline)
├── providers/       # State Management (Provider untuk Auth, Mood, Journal, Streak, Theme)
├── screens/         # Layar UI Aplikasi (Splash, Onboarding, Auth, Dashboard, dll.)
├── widgets/         # Widget UI premium yang dapat digunakan kembali (GlassCard, CustomButton, dll.)
└── main.dart        # Entry point aplikasi & inisialisasi state
```

---

## ⚙️ Cara Menjalankan Aplikasi

### 1. Prasyarat
- Flutter SDK (versi terbaru kompatibel Dart 3.9+)
- Emulator Android/iOS atau Perangkat Fisik tersambung.

### 2. Instalasi
Buka terminal di direktori proyek dan jalankan:
```bash
flutter pub get
```

### 3. Menjalankan Mode Offline / Simulasi (Default)
Secara default, aplikasi diluncurkan dalam **Mode Offline (Local Cache & Mock Data)**. Anda tidak memerlukan konfigurasi Firebase awal untuk mengujinya!
- Jalankan perintah:
  ```bash
  flutter run
  ```
- Anda dapat mendaftar akun baru dan langsung login. Semua data mood, jurnal, tingkat XP, dan lencana tersimpan aman di dalam penyimpanan perangkat (`SharedPreferences`).

---

## 🔗 Menghubungkan Firebase (Mode Cloud Produksi)

Jika Anda siap menyambungkannya ke Firebase Cloud Database dan Cloud Authentication, ikuti langkah berikut:

### Langkah 1: Buat Proyek Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Buat proyek baru bernama **Mindeva**.
3. Aktifkan layanan berikut:
   - **Firebase Authentication**: Aktifkan metode login menggunakan *Email/Password*.
   - **Cloud Firestore**: Buat database Firestore baru dalam *Test Mode* atau gunakan `firestore.rules` yang disediakan di root direktori.

### Langkah 2: Daftarkan Aplikasi Flutter ke Firebase
Gunakan alat `flutterfire CLI` untuk konfigurasi otomatis tercepat:
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```
Atau daftarkan secara manual:
- **Android**: Unduh berkas `google-services.json` dan letakkan di `android/app/`.
- **iOS**: Unduh berkas `GoogleService-Info.plist` dan letakkan di `ios/Runner/`.

### Langkah 3: Aktifkan Firebase di Kode
Buka berkas [lib/core/config.dart](file:///d:/SEMESTER%206/MANPRO/APK%20MINDEVA/lib/core/config.dart) dan ubah konstanta `useFirebase` menjadi `true`:
```dart
class AppConfig {
  static const bool useFirebase = true; // Setel ke true
  ...
}
```

Jalankan kembali aplikasi Anda. Mindeva sekarang akan melakukan sinkronisasi database dan autentikasi secara realtime ke cloud Firebase!

---

## 🧠 Mengaktifkan AI Gemini

1. Buka [Google AI Studio](https://aistudio.google.com/) dan buat **API Key** gratis.
2. Di dalam aplikasi Mindeva, Anda dapat memasukkan kunci tersebut melalui dua cara:
   - **Melalui UI Aplikasi (Direkomendasikan)**: Masuk ke Halaman **Profil** -> Ketuk **Gemini API Key** -> Tempel Key Anda dan Simpan.
   - **Melalui Kode (Default Fallback)**: Buka berkas [lib/services/gemini_service.dart](file:///d:/SEMESTER%206/MANPRO/APK%20MINDEVA/lib/services/gemini_service.dart) dan ubah konstanta `defaultApiKey`:
     ```dart
     static const String defaultApiKey = "KUNCI_API_GEMINI_ANDA_DI_SINI";
     ```

---

## ⚠️ Keamanan & Kontribusi (PENTING)
**Jangan pernah commit file yang mengandung API Keys atau Secret ke public repository.**
Pastikan file berikut sudah masuk dalam `.gitignore`:
- `android/app/google-services.json`
- `.env` (Jika Anda menggunakan environment variables)
- Jangan lupa hapus/hardcode API key dari `lib/main.dart` dan `lib/services/gemini_service.dart` sebelum melakukan push. (Saat ini sudah dihapus dan diganti dengan placeholder).
