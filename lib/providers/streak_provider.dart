import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/achievement_model.dart';
import '../services/local_storage_service.dart';
import '../core/config.dart';
import 'auth_provider.dart';

class StreakProvider extends ChangeNotifier {
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;
  
  // XP level calculation helper
  static const int xpPerLevel = 100;

  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;

  int getLevel(int xp) {
    return (xp / xpPerLevel).floor() + 1;
  }

  double getLevelProgress(int xp) {
    return (xp % xpPerLevel) / xpPerLevel;
  }

  int getNextLevelXp(int xp) {
    return (getLevel(xp)) * xpPerLevel;
  }

  Future<void> fetchAchievements(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (AppConfig.useFirebase) {
        // Firebase load
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .orderBy('unlockedAt', descending: true)
            .get();
        
        _achievements = snapshot.docs.map((doc) {
          return AchievementModel.fromMap(doc.data(), doc.id);
        }).toList();
      } else {
        // Local load
        final list = await LocalStorageService.getAchievements();
        _achievements = list.map((item) => AchievementModel.fromMap(item, item['achievementId'] ?? '')).toList();
      }
    } catch (e) {
      print("Error loading achievements: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Periksa apakah ada lencana baru yang terbuka
  Future<AchievementModel?> checkAndUnlockAchievements({
    required String userId,
    required int currentStreak,
    required int totalMoodLogs,
    required int totalJournals,
    required AuthProvider authProvider,
  }) async {
    await fetchAchievements(userId);
    AchievementModel? newlyUnlocked;

    // Helper untuk mengecek apakah badge sudah ada
    bool hasBadge(String title) => _achievements.any((a) => a.title == title);

    // 1. Badge: 7 Days Calm Streak
    if (currentStreak >= 7 && !hasBadge("7 Days Calm Streak")) {
      newlyUnlocked = await _unlockBadge(
        userId: userId,
        title: "7 Days Calm Streak",
        icon: "fire",
        description: "Menjaga streak kesehatan mental selama 7 hari berturut-turut!",
        authProvider: authProvider,
      );
    } 
    // 2. Badge: Consistent Journaler
    else if (totalJournals >= 3 && !hasBadge("Consistent Journaler")) {
      newlyUnlocked = await _unlockBadge(
        userId: userId,
        title: "Consistent Journaler",
        icon: "book",
        description: "Menulis minimal 3 entri jurnal untuk memahami emosi diri.",
        authProvider: authProvider,
      );
    } 
    // 3. Badge: Self Care Hero
    else if (totalMoodLogs >= 5 && !hasBadge("Self Care Hero")) {
      newlyUnlocked = await _unlockBadge(
        userId: userId,
        title: "Self Care Hero",
        icon: "leaf",
        description: "Mencatat mood sebanyak 5 kali sebagai kepedulian pada diri sendiri.",
        authProvider: authProvider,
      );
    }

    if (newlyUnlocked != null) {
      _achievements.insert(0, newlyUnlocked);
      notifyListeners();
    }

    return newlyUnlocked;
  }

  Future<AchievementModel> _unlockBadge({
    required String userId,
    required String title,
    required String icon,
    required String description,
    required AuthProvider authProvider,
  }) async {
    final badgeId = const Uuid().v4();
    final newBadge = AchievementModel(
      achievementId: badgeId,
      title: title,
      icon: icon,
      unlockedAt: DateTime.now(),
      description: description,
    );

    if (AppConfig.useFirebase) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(badgeId)
          .set(newBadge.toMap());
    } else {
      final list = await LocalStorageService.getAchievements();
      list.add(newBadge.toMap()..['achievementId'] = badgeId);
      await LocalStorageService.saveAchievements(list);
    }

    // Tambah bonus XP (+100 XP) untuk unlock lencana
    await authProvider.updateUserStats(addXp: 100);

    return newBadge;
  }
}
