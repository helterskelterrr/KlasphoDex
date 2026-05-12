# Prompt Perbaikan & Pengamanan Proyek CreatureLens

Gunakan prompt di bawah ini untuk menginstruksikan AI Agent (seperti saya) atau rekan developer Anda untuk memperbaiki isu-isu kritis pada proyek CreatureLens secara terstruktur.

---

**Konteks Proyek:**
Proyek ini adalah aplikasi game mobile Flutter bernama "CreatureLens". Aplikasi menggunakan arsitektur `flutter_riverpod` untuk state management, `go_router` untuk navigasi, dan `hive` untuk penyimpanan lokal. Terdapat integrasi *Computer Vision* (ML Kit) dan *Generative AI* (OpenRouter/Gemini API).

**Tujuan:**
Lakukan refaktorisasi dan perbaikan sistem untuk mengamankan data rahasia (API Key), memperbaiki stabilitas layanan AI, dan membangun pondasi untuk sinkronisasi Cloud (Firebase) agar tidak terjadi kehilangan data pengguna.

**Tugas yang Harus Dieksekusi:**

### Fase 1: Mengamankan API Key (Prioritas Kritis)
1. Tolong implementasikan *package* `flutter_dotenv` ke dalam proyek.
2. Buat file `.env` di *root directory* dan tambahkan konfigurasi `OPENROUTER_API_KEY=kunci_api_anda` (beritahu saya jika saya perlu memberikan kuncinya nanti).
3. Pastikan `.env` ditambahkan ke dalam file `.gitignore`.
4. Modifikasi fungsi `main()` di `lib/main.dart` untuk memuat `dotenv.load()`.
5. Refaktor `lib/services/gemini_service.dart` untuk menghapus kunci yang di-*hardcode* (`sk-or-v1-...`) dan menggantinya dengan pemanggilan dari `dotenv.env['OPENROUTER_API_KEY']`.

### Fase 2: Optimalisasi Stabilitas AI & Kualitas JSON (Prompt Engineering)
Tugas Anda di fase ini adalah melakukan modifikasi pada `lib/services/gemini_service.dart` untuk memastikan model `google/gemma-4-31b-it:free` selalu merespons dengan JSON murni yang solid dan kreatif. Lakukan 3 hal berikut:
1. **Turunkan Suhu (Temperature):** Tambahkan parameter `"temperature": 0.5` di dalam *body request* (JSON payload) `http.post` ke OpenRouter. Ini menyeimbangkan kreativitas (nama/lore) dan kepatuhan format (JSON).
2. **Kunci Format Response:** Pastikan *request body* tetap menyertakan `"response_format": {"type": "json_object"}`. (Jangan dihapus jika sudah ada).
3. **Tambahkan Few-Shot Prompting:** Modifikasi teks variabel `prompt` dengan menambahkan satu contoh konkret di bagian paling bawah aturan (Rules). Tambahkan persis string ini: 
   `Contoh Output yang Benar: {"name": "Ignis Fern", "type": "Fire", "rarity": "Rare", "hp": 65, "attack": 70, "defense": 40, "speed": 55, "abilities": [{"name": "Ember Spores", "description": "Ignites the air around it.", "type": "Fire"}], "lore": "Born from the ash of a burning forest."}`

### Fase 3: Fondasi Sinkronisasi Cloud (Offline-First Architecture)
Saat ini proyek sangat bergantung pada `Hive` untuk `CreatureStorage`, `DeckStorage`, dan `TrialResultStorage`. Jika aplikasi dihapus, data pemain hilang.
1. Buat abstraksi *Repository/Service* baru (misalnya `lib/services/sync_service.dart`).
2. Rancang struktur kelas yang memungkinkan aplikasi tetap membaca dan menulis ke `Hive` untuk kecepatan UI (*Offline-First*), tetapi memiliki antrean (*queue*) untuk menyinkronkan (push/pull) data tersebut ke Firebase Firestore di latar belakang (Background Sync).
3. Jangan langsung mengubah kode UI, cukup buat arsitektur service-nya dan jelaskan kepada saya bagaimana cara menyuntikkan (inject) *service* ini menggunakan Riverpod ke depannya.

**Aturan Penulisan Kode:**
- Ikuti standar *clean code* dan pertahankan arsitektur yang sudah ada.
- Jangan menghapus fungsionalitas UI dari `home_screen.dart` atau layar *Deckbuilder*.
- Gunakan `riverpod` dengan baik jika membuat *provider* baru.
- Berikan saya *diff* atau kode penuh dari setiap file yang diubah satu per satu.

---
