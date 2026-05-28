import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/config.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await AppConfig.authRepository.getCurrentUser();
      if (_user != null) {
        await _checkAndIncrementStreak();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cek dan tambah streak jika belum login hari ini
  Future<void> _checkAndIncrementStreak() async {
    if (_user == null) return;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastStreakDate = LocalStorageService.getLastStreakDate();

    if (lastStreakDate == todayStr) return; // Sudah login hari ini

    // Tambah streak +1 setiap hari login baru (tidak pernah berkurang)
    int newStreak;
    if (lastStreakDate != null) {
      final last = DateTime.tryParse(lastStreakDate);
      if (last != null) {
        final diff = today.difference(last).inDays;
        if (diff >= 1) {
          // Hari baru: tambah streak +1
          newStreak = (_user!.streak) + 1;
        } else {
          return; // Hari sama, skip
        }
      } else {
        newStreak = (_user!.streak) + 1;
      }
    } else {
      // Pertama kali login, streak tetap dari data atau mulai 1
      newStreak = _user!.streak > 0 ? _user!.streak : 1;
    }

    // Simpan tanggal hari ini
    await LocalStorageService.saveLastStreakDate(todayStr);

    // Update streak di local state
    _user = _user!.copyWith(streak: newStreak);

    // Simpan ke local storage
    await LocalStorageService.saveUser(_user!.toMap()..['userId'] = _user!.userId);

    // Jika Firebase aktif, update ke Firestore juga
    if (AppConfig.useFirebase) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.userId)
            .update({'streak': newStreak});
      } catch (_) {
        // Gagal update firebase, lanjut saja
      }
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await AppConfig.authRepository.signIn(email, password);
      await _checkAndIncrementStreak();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await AppConfig.authRepository.signUp(name, email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await AppConfig.authRepository.signInWithGoogle();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await AppConfig.authRepository.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await AppConfig.authRepository.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileName(String name) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      _user = await AppConfig.authRepository.updateProfile(name, _user!.profileImage);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menambahkan XP atau update streak dari aktivitas eksternal
  void updateUserStats({int? addXp, int? streak}) {
    if (_user == null) return;
    int currentXp = _user!.xp;
    int currentStreak = _user!.streak;

    if (addXp != null) currentXp += addXp;
    if (streak != null) currentStreak = streak;

    _user = _user!.copyWith(xp: currentXp, streak: currentStreak);
    notifyListeners();
  }

  String _parseError(dynamic error) {
    final str = error.toString().toLowerCase();
    if (str.contains('user-not-found') || str.contains('tidak ditemukan')) {
      return "Email belum terdaftar. Silakan buat akun.";
    } else if (str.contains('wrong-password') || str.contains('salah sandi') || str.contains('invalid-credential')) {
      return "Email atau Password salah.";
    } else if (str.contains('email-already-in-use') || str.contains('sudah digunakan')) {
      return "Email sudah terdaftar. Silakan gunakan email lain.";
    } else if (str.contains('weak-password') || str.contains('lemah')) {
      return "Password terlalu lemah. Minimal 6 karakter.";
    }
    return "Error: ${error.toString()}";
  }
}
