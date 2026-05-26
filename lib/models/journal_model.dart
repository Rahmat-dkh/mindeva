class AIJournalAnalysisModel {
  final List<String> tags;
  final String sentiment;
  final String affirmation;
  final List<String> solution;

  AIJournalAnalysisModel({
    required this.tags,
    required this.sentiment,
    required this.affirmation,
    this.solution = const [],
  });

  factory AIJournalAnalysisModel.fromMap(Map<String, dynamic> map) {
    return AIJournalAnalysisModel(
      tags: List<String>.from(map['tags'] ?? []),
      sentiment: map['sentiment'] ?? 'Netral',
      affirmation: map['affirmation'] ?? 'Semoga hari Anda menyenangkan.',
      solution: List<String>.from(map['solution'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tags': tags,
      'sentiment': sentiment,
      'affirmation': affirmation,
      'solution': solution,
    };
  }

  factory AIJournalAnalysisModel.empty() {
    return AIJournalAnalysisModel(
      tags: [],
      sentiment: 'Netral',
      affirmation: 'Semoga hari Anda menyenangkan.',
      solution: [],
    );
  }
}

class JournalModel {
  final String journalId;
  final String title;
  final String content;
  final String emotion;
  final AIJournalAnalysisModel? aiAnalysis;
  final DateTime createdAt;

  JournalModel({
    required this.journalId,
    required this.title,
    required this.content,
    required this.emotion,
    this.aiAnalysis,
    required this.createdAt,
  });

  factory JournalModel.fromMap(Map<String, dynamic> map, String documentId) {
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
      // Firestore Timestamp — akses via refleksi dinamis agar tidak import Firestore di sini
      try {
        parsedDate = (raw as dynamic).toDate() as DateTime;
      } catch (_) {
        parsedDate = DateTime.now();
      }
    }

    return JournalModel(
      journalId: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      emotion: map['emotion'] ?? 'neutral',
      aiAnalysis: map['aiAnalysis'] != null
          ? AIJournalAnalysisModel.fromMap(Map<String, dynamic>.from(map['aiAnalysis']))
          : null,
      createdAt: parsedDate,
    );
  }

  /// toMap() untuk penyimpanan lokal (SharedPreferences / JSON) — tidak menggunakan Timestamp
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'emotion': emotion,
      'aiAnalysis': aiAnalysis?.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// toFirestoreMap() untuk penyimpanan ke Cloud Firestore — menggunakan Timestamp
  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'content': content,
      'emotion': emotion,
      'aiAnalysis': aiAnalysis?.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

