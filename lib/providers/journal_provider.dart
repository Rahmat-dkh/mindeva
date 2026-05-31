import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_model.dart';
import '../core/config.dart';
import '../services/gemini_service.dart';
import 'auth_provider.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalModel> _journals = [];
  List<JournalModel> _filteredJournals = [];
  bool _isLoading = false;
  bool _isAnalyzingAI = false;
  String _searchQuery = '';
  DateTime? _selectedFilterDate;

  List<JournalModel> get journals {
    if (_searchQuery.isEmpty && _selectedFilterDate == null) {
      return _journals;
    }
    return _filteredJournals;
  }
  bool get isLoading => _isLoading;
  bool get isAnalyzingAI => _isAnalyzingAI;
  String get searchQuery => _searchQuery;
  DateTime? get selectedFilterDate => _selectedFilterDate;

  Future<void> fetchJournals(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _journals = await AppConfig.journalRepository.getJournals(userId);
      _applyFilterAndSearch();
    } catch (e) {
      print("Error fetching journals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<JournalModel?> addJournal({
    required String userId,
    required String title,
    required String content,
    required String manualEmotion,
    required AuthProvider authProvider,
  }) async {
    _isAnalyzingAI = true;
    notifyListeners();

    try {
      // 1. Panggil Gemini API untuk menganalisis tag & sentimen & afirmasi harian
      final aiAnalysis = await GeminiService.analyzeJournal(title, content);

      // Gunakan emosi terdeteksi otomatis atau emosi yang dipilih manual oleh user
      String finalEmotion = manualEmotion;
      if (aiAnalysis.tags.isNotEmpty) {
        final firstTag = aiAnalysis.tags.first.toLowerCase();
        if (firstTag.contains('bahagia') || firstTag.contains('senang')) {
          finalEmotion = 'happy';
        } else if (firstTag.contains('sedih') || firstTag.contains('kecewa')) {
          finalEmotion = 'sad';
        } else if (firstTag.contains('marah') || firstTag.contains('kesal')) {
          finalEmotion = 'angry';
        } else if (firstTag.contains('cemas') || firstTag.contains('khawatir')) {
          finalEmotion = 'anxious';
        }
      }

      // 2. Buat Model Jurnal
      final newJournal = JournalModel(
        journalId: const Uuid().v4(),
        title: title,
        content: content,
        emotion: finalEmotion,
        aiAnalysis: aiAnalysis,
        createdAt: DateTime.now(),
      );

      // 3. Simpan di Database
      final savedJournal = await AppConfig.journalRepository.addJournal(userId, newJournal);

      // 4. Update data lokal provider
      _journals.insert(0, savedJournal);
      _applyFilterAndSearch();

      // Tambah XP (+35 XP) untuk menulis jurnal
      await authProvider.updateUserStats(addXp: 35);

      return savedJournal;
    } catch (e) {
      print("Error adding journal: $e");
      return null;
    } finally {
      _isAnalyzingAI = false;
      notifyListeners();
    }
  }

  Future<void> updateJournal({
    required String userId,
    required String journalId,
    required String title,
    required String content,
    required String emotion,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final idx = _journals.indexWhere((j) => j.journalId == journalId);
      if (idx != -1) {
        final currentJournal = _journals[idx];
        
        AIJournalAnalysisModel? aiAnalysis = currentJournal.aiAnalysis;
        String finalEmotion = emotion;

        if (currentJournal.content != content || currentJournal.title != title) {
          aiAnalysis = await GeminiService.analyzeJournal(title, content);
          if (aiAnalysis.tags.isNotEmpty) {
            final firstTag = aiAnalysis.tags.first.toLowerCase();
            if (firstTag.contains('bahagia') || firstTag.contains('senang')) {
              finalEmotion = 'happy';
            } else if (firstTag.contains('sedih') || firstTag.contains('kecewa')) {
              finalEmotion = 'sad';
            } else if (firstTag.contains('marah') || firstTag.contains('kesal')) {
              finalEmotion = 'angry';
            } else if (firstTag.contains('cemas') || firstTag.contains('khawatir')) {
              finalEmotion = 'anxious';
            }
          }
        }

        final updated = JournalModel(
          journalId: journalId,
          title: title,
          content: content,
          emotion: finalEmotion,
          aiAnalysis: aiAnalysis,
          createdAt: currentJournal.createdAt,
        );

        await AppConfig.journalRepository.updateJournal(userId, updated);
        _journals[idx] = updated;
        _applyFilterAndSearch();
      }
    } catch (e) {
      print("Error updating journal: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJournal(String userId, String journalId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await AppConfig.journalRepository.deleteJournal(userId, journalId);
      _journals.removeWhere((j) => j.journalId == journalId);
      _applyFilterAndSearch();
    } catch (e) {
      print("Error deleting journal: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set pencarian kata kunci
  void search(String query) {
    _searchQuery = query;
    _applyFilterAndSearch();
  }

  // Set filter tanggal
  void setFilterDate(DateTime? date) {
    _selectedFilterDate = date;
    _applyFilterAndSearch();
  }

  // Bersihkan semua filter
  void clearFilters() {
    _searchQuery = '';
    _selectedFilterDate = null;
    _filteredJournals = [];
    notifyListeners();
  }

  void _applyFilterAndSearch() {
    _filteredJournals = _journals.where((j) {
      final matchesSearch = j.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.content.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesDate = true;
      if (_selectedFilterDate != null) {
        matchesDate = j.createdAt.year == _selectedFilterDate!.year &&
            j.createdAt.month == _selectedFilterDate!.month &&
            j.createdAt.day == _selectedFilterDate!.day;
      }

      return matchesSearch && matchesDate;
    }).toList();
    notifyListeners();
  }
}
