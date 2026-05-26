import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyUser = 'mindeva_user';
  static const String _keyMoods = 'mindeva_moods';
  static const String _keyJournals = 'mindeva_journals';
  static const String _keyAchievements = 'mindeva_achievements';
  static const String _keyStreakDate = 'mindeva_last_streak_date';
  static const String _keyGeminiKey = 'mindeva_gemini_api_key';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // API Key Gemini
  static Future<void> saveGeminiKey(String key) async {
    await init();
    await _prefs!.setString(_keyGeminiKey, key);
  }

  static String getGeminiKey() {
    return _prefs?.getString(_keyGeminiKey) ?? '';
  }

  // Auth User Offline
  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    await init();
    await _prefs!.setString(_keyUser, jsonEncode(userMap));
  }

  static Map<String, dynamic>? getUser() {
    final raw = _prefs?.getString(_keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    await init();
    await _prefs!.remove(_keyUser);
  }

  // Moods Offline
  static Future<List<Map<String, dynamic>>> getMoods() async {
    await init();
    final rawList = _prefs!.getStringList(_keyMoods) ?? [];
    return rawList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> saveMoods(List<Map<String, dynamic>> moods) async {
    await init();
    final list = moods.map((item) => jsonEncode(item)).toList();
    await _prefs!.setStringList(_keyMoods, list);
  }

  // Journals Offline
  static Future<List<Map<String, dynamic>>> getJournals() async {
    await init();
    final rawList = _prefs!.getStringList(_keyJournals) ?? [];
    return rawList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> saveJournals(List<Map<String, dynamic>> journals) async {
    await init();
    final list = journals.map((item) => jsonEncode(item)).toList();
    await _prefs!.setStringList(_keyJournals, list);
  }

  // Achievements Offline
  static Future<List<Map<String, dynamic>>> getAchievements() async {
    await init();
    final rawList = _prefs!.getStringList(_keyAchievements) ?? [];
    return rawList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> saveAchievements(List<Map<String, dynamic>> achievements) async {
    await init();
    final list = achievements.map((item) => jsonEncode(item)).toList();
    await _prefs!.setStringList(_keyAchievements, list);
  }

  // Last Streak Date
  static Future<void> saveLastStreakDate(String dateStr) async {
    await init();
    await _prefs!.setString(_keyStreakDate, dateStr);
  }

  static String? getLastStreakDate() {
    return _prefs?.getString(_keyStreakDate);
  }

  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}
