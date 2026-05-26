import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_model.dart';
import '../core/config.dart';
import '../services/gemini_service.dart';
import '../services/local_storage_service.dart';
import 'auth_provider.dart';

class MoodProvider extends ChangeNotifier {
  List<MoodModel> _moodLogs = [];
  bool _isLoading = false;
  bool _isAnalyzingAI = false;

  List<MoodModel> get moodLogs => _moodLogs;
  bool get isLoading => _isLoading;
  bool get isAnalyzingAI => _isAnalyzingAI;

  Future<void> fetchMoodLogs(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _moodLogs = await AppConfig.moodRepository.getMoodLogs(userId);
    } catch (e) {
      print("Error fetching moods: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MoodModel?> addMood({
    required String userId,
    required String mood,
    required String note,
    required AuthProvider authProvider,
  }) async {
    _isAnalyzingAI = true;
    notifyListeners();

    try {
      // 1. Panggil Gemini API untuk mendapatkan analisis AI
      final analysis = await GeminiService.analyzeMood(mood, note);

      // 2. Buat Model Mood
      final newMood = MoodModel(
        moodId: const Uuid().v4(),
        mood: mood,
        note: note,
        aiAnalysis: analysis,
        createdAt: DateTime.now(),
      );

      // 3. Simpan di Database
      final savedMood = await AppConfig.moodRepository.addMoodLog(userId, newMood);

      // 4. Update data lokal provider
      _moodLogs.insert(0, savedMood);
      
      // 5. Update Streak & XP
      await _checkAndUpdateStreak(authProvider);
      
      // Tambah XP (+20 XP) untuk log mood
      authProvider.updateUserStats(addXp: 20);

      return savedMood;
    } catch (e) {
      print("Error adding mood: $e");
      return null;
    } finally {
      _isAnalyzingAI = false;
      notifyListeners();
    }
  }

  Future<void> updateMood({
    required String userId,
    required String moodId,
    required String mood,
    required String note,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final idx = _moodLogs.indexWhere((m) => m.moodId == moodId);
      if (idx != -1) {
        final currentMood = _moodLogs[idx];
        
        // Panggil kembali analisis AI jika catatan berubah
        AIAnalysisModel? analysis = currentMood.aiAnalysis;
        if (currentMood.note != note || currentMood.mood != mood) {
          analysis = await GeminiService.analyzeMood(mood, note);
        }

        final updated = MoodModel(
          moodId: moodId,
          mood: mood,
          note: note,
          aiAnalysis: analysis,
          createdAt: currentMood.createdAt,
        );

        await AppConfig.moodRepository.updateMoodLog(userId, updated);
        _moodLogs[idx] = updated;
      }
    } catch (e) {
      print("Error updating mood: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMood(String userId, String moodId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await AppConfig.moodRepository.deleteMoodLog(userId, moodId);
      _moodLogs.removeWhere((m) => m.moodId == moodId);
    } catch (e) {
      print("Error deleting mood: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cek streak harian
  Future<void> _checkAndUpdateStreak(AuthProvider authProvider) async {
    final user = authProvider.user;
    if (user == null) return;

    final todayStr = _formatDateKey(DateTime.now());
    final lastStreakDate = LocalStorageService.getLastStreakDate();

    if (lastStreakDate == null) {
      // Streak pertama kali
      await LocalStorageService.saveLastStreakDate(todayStr);
      authProvider.updateUserStats(streak: 1);
    } else {
      final lastDate = DateTime.parse(lastStreakDate);
      final difference = DateTime.now().difference(lastDate).inDays;

      if (difference == 1) {
        // Melanjutkan streak
        await LocalStorageService.saveLastStreakDate(todayStr);
        authProvider.updateUserStats(streak: user.streak + 1);
      } else if (difference > 1) {
        // Streak putus, reset kembali ke 1
        await LocalStorageService.saveLastStreakDate(todayStr);
        authProvider.updateUserStats(streak: 1);
      }
      // Jika difference == 0, berarti sudah log hari ini, jangan tambah streak
    }
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
