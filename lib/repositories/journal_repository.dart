import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';
import '../services/local_storage_service.dart';

abstract class JournalRepository {
  Future<List<JournalModel>> getJournals(String userId);
  Future<JournalModel> addJournal(String userId, JournalModel journal);
  Future<void> updateJournal(String userId, JournalModel journal);
  Future<void> deleteJournal(String userId, String journalId);
}

// -------------------------------------------------------------
// IMPLEMENTASI MOCK / OFFLINE LOCAL
// -------------------------------------------------------------
class MockJournalRepository implements JournalRepository {
  @override
  Future<List<JournalModel>> getJournals(String userId) async {
    final list = await LocalStorageService.getJournals();
    return list.map((item) => JournalModel.fromMap(item, item['journalId'] ?? '')).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<JournalModel> addJournal(String userId, JournalModel journal) async {
    final list = await LocalStorageService.getJournals();
    final data = journal.toMap()..['journalId'] = journal.journalId;
    list.add(data);
    await LocalStorageService.saveJournals(list);
    return journal;
  }

  @override
  Future<void> updateJournal(String userId, JournalModel journal) async {
    final list = await LocalStorageService.getJournals();
    final index = list.indexWhere((item) => item['journalId'] == journal.journalId);
    if (index != -1) {
      list[index] = journal.toMap()..['journalId'] = journal.journalId;
      await LocalStorageService.saveJournals(list);
    }
  }

  @override
  Future<void> deleteJournal(String userId, String journalId) async {
    final list = await LocalStorageService.getJournals();
    list.removeWhere((item) => item['journalId'] == journalId);
    await LocalStorageService.saveJournals(list);
  }
}

// -------------------------------------------------------------
// IMPLEMENTASI FIREBASE CLOUD
// -------------------------------------------------------------
class FirebaseJournalRepository implements JournalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _journalsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('journals');
  }

  @override
  Future<List<JournalModel>> getJournals(String userId) async {
    final snapshot = await _journalsRef(userId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return JournalModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  @override
  Future<JournalModel> addJournal(String userId, JournalModel journal) async {
    final docRef = _journalsRef(userId).doc(journal.journalId);
    await docRef.set(journal.toFirestoreMap());
    
    // Sinkronisasi lokal untuk cache offline
    final localList = await LocalStorageService.getJournals();
    localList.add(journal.toMap()..['journalId'] = journal.journalId);
    await LocalStorageService.saveJournals(localList);
    
    // Perbarui XP di dokumen user
    await _firestore.collection('users').doc(userId).update({
      'xp': FieldValue.increment(35), // Jurnal memberikan 35 XP
    });

    return journal;
  }

  @override
  Future<void> updateJournal(String userId, JournalModel journal) async {
    await _journalsRef(userId).doc(journal.journalId).update(journal.toFirestoreMap());
    
    // Sinkronisasi lokal
    final localList = await LocalStorageService.getJournals();
    final idx = localList.indexWhere((item) => item['journalId'] == journal.journalId);
    if (idx != -1) {
      localList[idx] = journal.toMap()..['journalId'] = journal.journalId;
      await LocalStorageService.saveJournals(localList);
    }
  }

  @override
  Future<void> deleteJournal(String userId, String journalId) async {
    await _journalsRef(userId).doc(journalId).delete();
    
    // Sinkronisasi lokal
    final localList = await LocalStorageService.getJournals();
    localList.removeWhere((item) => item['journalId'] == journalId);
    await LocalStorageService.saveJournals(localList);
  }
}
