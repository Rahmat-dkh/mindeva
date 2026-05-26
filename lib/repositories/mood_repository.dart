import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_model.dart';
import '../services/local_storage_service.dart';

abstract class MoodRepository {
  Future<List<MoodModel>> getMoodLogs(String userId);
  Future<MoodModel> addMoodLog(String userId, MoodModel mood);
  Future<void> updateMoodLog(String userId, MoodModel mood);
  Future<void> deleteMoodLog(String userId, String moodId);
}

// -------------------------------------------------------------
// IMPLEMENTASI MOCK / OFFLINE LOCAL
// -------------------------------------------------------------
class MockMoodRepository implements MoodRepository {
  @override
  Future<List<MoodModel>> getMoodLogs(String userId) async {
    final list = await LocalStorageService.getMoods();
    return list.map((item) => MoodModel.fromMap(item, item['moodId'] ?? '')).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<MoodModel> addMoodLog(String userId, MoodModel mood) async {
    final list = await LocalStorageService.getMoods();
    final data = mood.toMap()..['moodId'] = mood.moodId;
    list.add(data);
    await LocalStorageService.saveMoods(list);
    return mood;
  }

  @override
  Future<void> updateMoodLog(String userId, MoodModel mood) async {
    final list = await LocalStorageService.getMoods();
    final index = list.indexWhere((item) => item['moodId'] == mood.moodId);
    if (index != -index) {
      list[index] = mood.toMap()..['moodId'] = mood.moodId;
      await LocalStorageService.saveMoods(list);
    }
  }

  @override
  Future<void> deleteMoodLog(String userId, String moodId) async {
    final list = await LocalStorageService.getMoods();
    list.removeWhere((item) => item['moodId'] == moodId);
    await LocalStorageService.saveMoods(list);
  }
}

// -------------------------------------------------------------
// IMPLEMENTASI FIREBASE CLOUD
// -------------------------------------------------------------
class FirebaseMoodRepository implements MoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _moodsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('moods');
  }

  @override
  Future<List<MoodModel>> getMoodLogs(String userId) async {
    final snapshot = await _moodsRef(userId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return MoodModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  @override
  Future<MoodModel> addMoodLog(String userId, MoodModel mood) async {
    final docRef = _moodsRef(userId).doc(mood.moodId);
    await docRef.set(mood.toFirestoreMap());
    
    // Sinkronisasi lokal untuk cache offline
    final localList = await LocalStorageService.getMoods();
    localList.add(mood.toMap()..['moodId'] = mood.moodId);
    await LocalStorageService.saveMoods(localList);
    
    // Perbarui jumlah log di dokumen user
    await _firestore.collection('users').doc(userId).update({
      'totalMoodLogs': FieldValue.increment(1),
      'xp': FieldValue.increment(20), // Dapatkan 20 XP untuk log mood
    });

    return mood;
  }

  @override
  Future<void> updateMoodLog(String userId, MoodModel mood) async {
    await _moodsRef(userId).doc(mood.moodId).update(mood.toFirestoreMap());
    
    // Sinkronisasi lokal
    final localList = await LocalStorageService.getMoods();
    final idx = localList.indexWhere((item) => item['moodId'] == mood.moodId);
    if (idx != -1) {
      localList[idx] = mood.toMap()..['moodId'] = mood.moodId;
      await LocalStorageService.saveMoods(localList);
    }
  }

  @override
  Future<void> deleteMoodLog(String userId, String moodId) async {
    await _moodsRef(userId).doc(moodId).delete();
    
    // Sinkronisasi lokal
    final localList = await LocalStorageService.getMoods();
    localList.removeWhere((item) => item['moodId'] == moodId);
    await LocalStorageService.saveMoods(localList);

    await _firestore.collection('users').doc(userId).update({
      'totalMoodLogs': FieldValue.increment(-1),
    });
  }
}
