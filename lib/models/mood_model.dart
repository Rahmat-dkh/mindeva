class AIAnalysisModel {
  final int stressLevel; // 1 to 5
  final String emotionalState;
  final String moodTrend;
  final String sentiment;
  final String motivation;
  final List<String> recommendations;

  AIAnalysisModel({
    required this.stressLevel,
    required this.emotionalState,
    required this.moodTrend,
    required this.sentiment,
    required this.motivation,
    required this.recommendations,
  });

  factory AIAnalysisModel.fromMap(Map<String, dynamic> map) {
    return AIAnalysisModel(
      stressLevel: map['stressLevel'] ?? 3,
      emotionalState: map['emotionalState'] ?? 'Stabil',
      moodTrend: map['moodTrend'] ?? 'Normal',
      sentiment: map['sentiment'] ?? 'Netral',
      motivation: map['motivation'] ?? '',
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stressLevel': stressLevel,
      'emotionalState': emotionalState,
      'moodTrend': moodTrend,
      'sentiment': sentiment,
      'motivation': motivation,
      'recommendations': recommendations,
    };
  }

  factory AIAnalysisModel.empty() {
    return AIAnalysisModel(
      stressLevel: 1,
      emotionalState: 'Tidak teranalisis',
      moodTrend: 'Tidak ada tren',
      sentiment: 'Netral',
      motivation: 'Tulis catatan mood yang lebih panjang untuk memulai analisis AI.',
      recommendations: ['Tulis jurnal harian Anda', 'Cobalah latihan pernapasan'],
    );
  }
}

class MoodModel {
  final String moodId;
  final String mood; // happy, neutral, sad, angry, anxious
  final String note;
  final AIAnalysisModel? aiAnalysis;
  final DateTime createdAt;

  MoodModel({
    required this.moodId,
    required this.mood,
    required this.note,
    this.aiAnalysis,
    required this.createdAt,
  });

  factory MoodModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Mendukung Firestore Timestamp, int (millisecondsSinceEpoch), dan String ISO
    DateTime parsedDate;
    final raw = map['createdAt'];
    if (raw == null) {
      parsedDate = DateTime.now();
    } else if (raw is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(raw);
    } else if (raw is String) {
      parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      try {
        parsedDate = (raw as dynamic).toDate() as DateTime;
      } catch (_) {
        parsedDate = DateTime.now();
      }
    }

    return MoodModel(
      moodId: documentId,
      mood: map['mood'] ?? 'neutral',
      note: map['note'] ?? '',
      aiAnalysis: map['aiAnalysis'] != null
          ? AIAnalysisModel.fromMap(Map<String, dynamic>.from(map['aiAnalysis']))
          : null,
      createdAt: parsedDate,
    );
  }

  /// toMap() untuk penyimpanan lokal (SharedPreferences / JSON)
  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'note': note,
      'aiAnalysis': aiAnalysis?.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// toFirestoreMap() untuk Cloud Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'mood': mood,
      'note': note,
      'aiAnalysis': aiAnalysis?.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

