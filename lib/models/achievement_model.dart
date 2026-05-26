import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementModel {
  final String achievementId;
  final String title;
  final String icon; // Icon key (e.g. fire, book, leaf)
  final DateTime unlockedAt;
  final String description;

  AchievementModel({
    required this.achievementId,
    required this.title,
    required this.icon,
    required this.unlockedAt,
    required this.description,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AchievementModel(
      achievementId: documentId,
      title: map['title'] ?? '',
      icon: map['icon'] ?? 'star',
      unlockedAt: map['unlockedAt'] != null
          ? (map['unlockedAt'] as Timestamp).toDate()
          : DateTime.now(),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'description': description,
    };
  }
}
