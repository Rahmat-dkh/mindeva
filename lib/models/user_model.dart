class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? profileImage;
  final int streak;
  final int totalMoodLogs;
  final int xp;
  final bool isPremium;
  final String role; // 'user' or 'psychologist'
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.profileImage,
    this.streak = 0,
    this.totalMoodLogs = 0,
    this.xp = 0,
    this.isPremium = false,
    this.role = 'user',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Mendukung Firestore Timestamp, int (milliseconds), dan String ISO
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

    return UserModel(
      userId: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      streak: map['streak'] ?? 0,
      totalMoodLogs: map['totalMoodLogs'] ?? 0,
      xp: map['xp'] ?? 0,
      isPremium: map['isPremium'] == true,
      role: map['role'] ?? 'user',
      createdAt: parsedDate,
    );
  }

  /// toMap() untuk penyimpanan lokal (SharedPreferences / JSON)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'streak': streak,
      'totalMoodLogs': totalMoodLogs,
      'xp': xp,
      'isPremium': isPremium,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// toFirestoreMap() untuk Cloud Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'streak': streak,
      'totalMoodLogs': totalMoodLogs,
      'xp': xp,
      'isPremium': isPremium,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profileImage,
    int? streak,
    int? totalMoodLogs,
    int? xp,
    bool? isPremium,
    String? role,
  }) {
    return UserModel(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      streak: streak ?? this.streak,
      totalMoodLogs: totalMoodLogs ?? this.totalMoodLogs,
      xp: xp ?? this.xp,
      isPremium: isPremium ?? this.isPremium,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }
}

