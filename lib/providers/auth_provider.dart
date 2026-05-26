import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/config.dart';

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
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await AppConfig.authRepository.signIn(email, password);
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
