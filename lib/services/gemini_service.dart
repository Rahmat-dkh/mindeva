import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/mood_model.dart';
import '../models/journal_model.dart';
import '../core/api_keys.dart'; // Import ApiKeys

class GeminiService {
  // Key default untuk fallback (opsional, jika tidak diset, user bisa input di settings)
  static const String defaultApiKey = ApiKeys.geminiApiKey; // Menggunakan API Key dari file lokal

  static String get _apiKey => defaultApiKey;

  // Melakukan analisis catatan mood
  static Future<AIAnalysisModel> analyzeMood(String mood, String note) async {
    final key = _apiKey;
    if (key.isEmpty || key.contains("YOUR_GEMINI")) {
      return _generateLocalFallbackAnalysis(mood, note);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: key,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
Kamu adalah AI psikolog/pendamping kesehatan mental yang empati. Analisis data berikut:
Mood: $mood
Catatan Harian: $note

Berikan hasil analisis emosi dalam format JSON dengan struktur persis seperti berikut:
{
  "stressLevel": [angka integer 1 sampai 5],
  "emotionalState": "[penjelasan singkat emosi saat ini dalam Bahasa Indonesia, maks 5 kata]",
  "moodTrend": "[tren emosional singkat, misal: Meningkat, Stabil, Menurun, Cemas]",
  "sentiment": "[Positif / Netral / Negatif]",
  "motivation": "[afirmasi/kalimat motivasi empati personal sesuai input, maks 20 kata dalam Bahasa Indonesia]",
  "recommendations": [
    "[rekomendasi self-care 1 dalam Bahasa Indonesia]",
    "[rekomendasi self-care 2 dalam Bahasa Indonesia]",
    "[rekomendasi self-care 3 dalam Bahasa Indonesia]"
  ]
}
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        final decoded = jsonDecode(responseText) as Map<String, dynamic>;
        return AIAnalysisModel.fromMap(decoded);
      }
    } catch (e) {
      print("Gemini API Error: $e");
    }

    return _generateLocalFallbackAnalysis(mood, note);
  }

  // Melakukan analisis & tagging otomatis tulisan jurnal
  static Future<AIJournalAnalysisModel> analyzeJournal(String title, String contentText) async {
    final key = _apiKey;
    if (key.isEmpty || key.contains("YOUR_GEMINI")) {
      return _generateLocalJournalFallback(title, contentText);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: key,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
Kamu adalah asisten jurnal kesehatan mental. Analisis isi jurnal berikut:
Judul: $title
Isi: $contentText

Berikan hasil analisis dalam format JSON dengan struktur persis seperti berikut:
{
  "tags": ["[tag emosi 1]", "[tag emosi 2]", "[tag emosi 3]"],
  "sentiment": "[Positif / Netral / Negatif]",
  "affirmation": "[afirmasi positif personal sesuai isi jurnal dalam Bahasa Indonesia, maks 20 kata]"
}
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        final decoded = jsonDecode(responseText) as Map<String, dynamic>;
        return AIJournalAnalysisModel.fromMap(decoded);
      }
    } catch (e) {
      print("Gemini API Error (Journal): $e");
    }

    return _generateLocalJournalFallback(title, contentText);
  }

  // Mendapatkan solusi/langkah nyata dari isi jurnal
  static Future<List<String>> getJournalSolution(String title, String contentText) async {
    final key = _apiKey;
    if (key.isEmpty || key.contains("YOUR_GEMINI")) {
      return _generateLocalSolution(contentText);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: key,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
Kamu adalah konselor kesehatan mental yang bijak dan empatik. Baca jurnal refleksi berikut dan berikan solusi tindakan nyata yang bisa langsung dilakukan.

Judul: $title
Isi Jurnal: $contentText

Berikan 4 solusi praktis dalam format JSON. Setiap solusi harus SPESIFIK sesuai konteks jurnal, DAPAT DILAKUKAN HARI INI, dan disampaikan dengan penuh kehangatan.

{
  "solutions": [
    "[Solusi praktis 1, maks 20 kata, dalam Bahasa Indonesia]",
    "[Solusi praktis 2, maks 20 kata, dalam Bahasa Indonesia]",
    "[Solusi praktis 3, maks 20 kata, dalam Bahasa Indonesia]",
    "[Solusi praktis 4, maks 20 kata, dalam Bahasa Indonesia]"
  ]
}
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        final decoded = jsonDecode(responseText) as Map<String, dynamic>;
        return List<String>.from(decoded['solutions'] ?? []);
      }
    } catch (e) {
      print("Gemini Solution Error: $e");
    }

    return _generateLocalSolution(contentText);
  }

  // Fallback solusi lokal berbasis keyword
  static List<String> _generateLocalSolution(String contentText) {
    final lower = contentText.toLowerCase();

    if (lower.contains('cemas') || lower.contains('khawatir') || lower.contains('takut')) {
      return [
        "Coba teknik pernapasan 4-7-8: hirup 4 detik, tahan 7 detik, hembuskan 8 detik.",
        "Tulis 3 hal yang bisa kamu kendalikan saat ini di selembar kertas.",
        "Gunakan fitur Latihan Pernapasan di Mindeva selama 5 menit.",
        "Hubungi orang terdekat yang bisa diajak bicara tentang perasaanmu.",
      ];
    } else if (lower.contains('sedih') || lower.contains('kecewa') || lower.contains('nangis')) {
      return [
        "Izinkan dirimu merasakan kesedihan — menangis itu menyehatkan, bukan lemah.",
        "Putar lagu favorit yang menenangkan dan nikmati selama 10 menit.",
        "Tulis satu hal kecil yang masih bisa kamu syukuri hari ini.",
        "Istirahat tidur lebih awal malam ini untuk memulihkan energi emosional.",
      ];
    } else if (lower.contains('marah') || lower.contains('kesal') || lower.contains('frustrasi')) {
      return [
        "Coba 'box breathing': hirup, tahan, hembuskan, tahan — masing-masing 4 detik.",
        "Olahraga ringan seperti jalan cepat 10 menit untuk melepas adrenalin.",
        "Tuliskan semua kemarahanmu di kertas lalu sobek — melepaskan secara simbolis.",
        "Tunggu 24 jam sebelum merespons situasi yang membuatmu marah.",
      ];
    } else if (lower.contains('lelah') || lower.contains('capek') || lower.contains('burnout')) {
      return [
        "Jadwalkan 20-30 menit 'me time' tanpa gawai hari ini.",
        "Identifikasi satu tugas yang bisa kamu delegasikan atau tunda besok.",
        "Minum segelas air dan konsumsi makanan bergizi untuk memulihkan energi.",
        "Tidur siang singkat 15-20 menit jika memungkinkan untuk restorasi otak.",
      ];
    } else if (lower.contains('senang') || lower.contains('bahagia') || lower.contains('bersyukur')) {
      return [
        "Catat momen bahagia ini di 'Jurnal Syukur' agar bisa dibaca saat sedih nanti.",
        "Bagikan kebahagiaanmu dengan menghubungi satu orang yang kamu sayangi.",
        "Rayakan pencapaianmu — manjakan dirimu dengan sesuatu yang kamu sukai.",
        "Gunakan energi positif ini untuk mulai sesuatu yang sudah lama ditunda.",
      ];
    } else {
      return [
        "Luangkan 5 menit untuk duduk diam dan bernapas dengan penuh kesadaran (mindfulness).",
        "Tulis satu tujuan kecil yang ingin kamu capai besok agar hari terasa bermakna.",
        "Beritahu satu orang yang kamu percaya tentang perasaanmu hari ini.",
        "Lakukan satu aktivitas fisik ringan — peregangan atau jalan-jalan singkat.",
      ];
    }
  }

  // Fallback lokal jika API key bermasalah atau belum diatur
  static AIAnalysisModel _generateLocalFallbackAnalysis(String mood, String note) {
    int stress = 3;
    String emotionalState = "Stabil";
    String trend = "Normal";
    String sentiment = "Netral";
    String motivation = "Setiap emosi valid. Teruslah berproses, kamu berharga.";
    List<String> recommendations = [
      "Luangkan waktu 5 menit untuk relaksasi bernapas.",
      "Tuliskan hal-hal kecil yang Anda syukuri hari ini.",
      "Jalan kaki santai sejenak untuk menyegarkan pikiran."
    ];

    final lowerNote = note.toLowerCase();
    if (mood == 'happy') {
      stress = 1;
      emotionalState = "Sangat Bahagia & Berenergi";
      trend = "Positif";
      sentiment = "Positif";
      motivation = "Hari yang luar biasa! Pertahankan energi positif ini dan sebarkan kebaikan.";
      recommendations = [
        "Rayakan pencapaian kecilmu hari ini.",
        "Bagikan kebahagiaanmu dengan menelepon orang terdekat.",
        "Catat apa yang membuatmu sangat bahagia agar bisa dibaca nanti."
      ];
    } else if (mood == 'sad') {
      stress = 4;
      emotionalState = "Sedih & Melankolis";
      trend = "Menurun";
      sentiment = "Negatif";
      motivation = "Tidak apa-apa merasa sedih. Awan gelap pasti akan berlalu, tarik napas perlahan.";
      recommendations = [
        "Lakukan aktivitas kegemaran Anda (menonton, membaca, menyeduh teh hangat).",
        "Dengarkan musik yang menenangkan pikiran.",
        "Istirahat tidur lebih awal malam ini."
      ];
    } else if (mood == 'angry') {
      stress = 5;
      emotionalState = "Frustrasi & Gelisah";
      trend = "Tegang";
      sentiment = "Negatif";
      motivation = "Kemarahan adalah emosi alami. Salurkan secara perlahan melalui tarikan napas.";
      recommendations = [
        "Coba latihan pernapasan kotak (box breathing) di aplikasi ini.",
        "Cobalah menuliskan kemarahan Anda di kertas lalu merobeknya.",
        "Cuci muka atau mandi air dingin untuk menurunkan suhu tubuh."
      ];
    } else if (mood == 'anxious') {
      stress = 4;
      emotionalState = "Khawatir & Overthinking";
      trend = "Cemas";
      sentiment = "Negatif";
      motivation = "Fokus pada apa yang bisa kamu kendalikan saat ini. Tarik napas, kamu aman.";
      recommendations = [
        "Lakukan teknik grounding 5-4-3-2-1 (sebutkan benda di sekitarmu).",
        "Gunakan fitur Latihan Pernapasan di Mindeva.",
        "Tulis semua kecemasan Anda di jurnal untuk mengurangi beban pikiran."
      ];
    } else {
      // Neutral
      if (lowerNote.contains('lelah') || lowerNote.contains('capek')) {
        stress = 4;
        emotionalState = "Kelelahan Fisik/Mental";
        motivation = "Tubuhmu sedang memberi sinyal untuk beristirahat. Sayangi dirimu.";
        recommendations = ["Kurangi screen time malam ini", "Tidur 7-8 jam", "Minum air putih yang cukup"];
      }
    }

    return AIAnalysisModel(
      stressLevel: stress,
      emotionalState: emotionalState,
      moodTrend: trend,
      sentiment: sentiment,
      motivation: motivation,
      recommendations: recommendations,
    );
  }

  static AIJournalAnalysisModel _generateLocalJournalFallback(String title, String contentText) {
    final lowerContent = contentText.toLowerCase();
    List<String> tags = ['Refleksi'];
    String sentiment = "Netral";
    String affirmation = "Setiap tulisan adalah langkah menuju kesadaran diri.";

    if (lowerContent.contains('senang') || lowerContent.contains('bahagia') || lowerContent.contains('bersyukur')) {
      tags = ['Bahagia', 'Syukur', 'Energi'];
      sentiment = "Positif";
      affirmation = "Fokus pada hal positif hari ini akan memperkuat ketahanan mental Anda.";
    } else if (lowerContent.contains('sedih') || lowerContent.contains('kecewa') || lowerContent.contains('nangis')) {
      tags = ['Kesedihan', 'Pelepasan', 'Melankolis'];
      sentiment = "Negatif";
      affirmation = "Mengakui kesedihan adalah bentuk keberanian. Hari esok membawa harapan baru.";
    } else if (lowerContent.contains('marah') || lowerContent.contains('kesal') || lowerContent.contains('benci')) {
      tags = ['Kemarahan', 'Frustrasi', 'Ketegangan'];
      sentiment = "Negatif";
      affirmation = "Kemarahan Anda valid. Salurkan dengan bijak dan bebaskan dirimu secara perlahan.";
    } else if (lowerContent.contains('takut') || lowerContent.contains('cemas') || lowerContent.contains('khawatir') || lowerContent.contains('bingung')) {
      tags = ['Kecemasan', 'Keraguan', 'Overthinking'];
      sentiment = "Negatif";
      affirmation = "Kekhawatiran adalah awan yang lewat. Anda kuat dan mampu menghadapinya.";
    }

    return AIJournalAnalysisModel(
      tags: tags,
      sentiment: sentiment,
      affirmation: affirmation,
    );
  }
}
