import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

abstract class AuthRepository {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String name, String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile(String name, String? profileImage);
  Future<UserModel> signInWithGoogle();
}

// -------------------------------------------------------------
// IMPLEMENTASI MOCK / OFFLINE LOCAL
// -------------------------------------------------------------
class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulasi network delay
    final existingUser = LocalStorageService.getUser();
    if (existingUser != null && existingUser['email'] == email) {
      return UserModel.fromMap(existingUser, existingUser['userId'] ?? 'mock_uid_123');
    }
    
    // Default mock user jika belum terdaftar
    final newUser = UserModel(
      userId: 'mock_uid_123',
      name: email.split('@')[0].toUpperCase(),
      email: email,
      createdAt: DateTime.now(),
      streak: 3,
      totalMoodLogs: 5,
      xp: 150,
    );
    await LocalStorageService.saveUser(newUser.toMap()..['userId'] = newUser.userId);
    return newUser;
  }

  @override
  Future<UserModel> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newUser = UserModel(
      userId: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: DateTime.now(),
      streak: 1,
      totalMoodLogs: 0,
      xp: 50,
    );
    await LocalStorageService.saveUser(newUser.toMap()..['userId'] = newUser.userId);
    return newUser;
  }

  @override
  Future<void> signOut() async {
    await LocalStorageService.clearUser();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final map = LocalStorageService.getUser();
    if (map == null) return null;
    return UserModel.fromMap(map, map['userId'] ?? 'mock_uid_123');
  }

  @override
  Future<UserModel> updateProfile(String name, String? profileImage) async {
    final current = await getCurrentUser();
    if (current == null) throw Exception("User not logged in");
    final updated = current.copyWith(name: name, profileImage: profileImage);
    await LocalStorageService.saveUser(updated.toMap()..['userId'] = updated.userId);
    return updated;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newUser = UserModel(
      userId: 'mock_google_uid_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'user@gmail.com',
      createdAt: DateTime.now(),
      streak: 1,
      totalMoodLogs: 0,
      xp: 50,
    );
    await LocalStorageService.saveUser(newUser.toMap()..['userId'] = newUser.userId);
    return newUser;
  }
}

// -------------------------------------------------------------
// IMPLEMENTASI FIREBASE CLOUD
// -------------------------------------------------------------
class FirebaseAuthRepository implements AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) throw Exception("Gagal masuk: Pengguna kosong");
    return await _getUserFromFirestore(credential.user!.uid);
  }

  @override
  Future<UserModel> signUp(String name, String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) throw Exception("Gagal mendaftar: Pengguna kosong");

    final uid = credential.user!.uid;
    final newUser = UserModel(
      userId: uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      streak: 1,
      totalMoodLogs: 0,
      xp: 50,
    );

    // Simpan ke Firestore
    await _firestore.collection('users').doc(uid).set(newUser.toFirestoreMap());
    
    // Sinkronisasi lokal untuk cache
    await LocalStorageService.saveUser(newUser.toMap()..['userId'] = uid);

    return newUser;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await LocalStorageService.clearUser();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      // Jika firebase offline atau mati, cek cache lokal
      final localMap = LocalStorageService.getUser();
      if (localMap != null) return UserModel.fromMap(localMap, localMap['userId']);
      return null;
    }
    return await _getUserFromFirestore(fbUser.uid);
  }

  @override
  Future<UserModel> updateProfile(String name, String? profileImage) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) throw Exception("Pengguna tidak terautentikasi");
    
    final uid = fbUser.uid;
    final userDoc = _firestore.collection('users').doc(uid);
    
    await userDoc.update({
      'name': name,
      if (profileImage != null) 'profileImage': profileImage,
    });

    final updatedUser = await _getUserFromFirestore(uid);
    await LocalStorageService.saveUser(updatedUser.toMap()..['userId'] = uid);
    return updatedUser;
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception("Data pengguna tidak ditemukan di database");
    }
    return UserModel.fromMap(doc.data()!, uid);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Note: For Web, you MUST provide the Web Client ID from Firebase Console.
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: '374294558680-glhbt4264021acs7evd2oeq8lui5ii0d.apps.googleusercontent.com',
    );
    
    // Mulai proses login Google
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      throw Exception("Login dibatalkan");
    }

    // Dapatkan kredensial autentikasi dari request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Buat kredensial baru untuk Firebase
    final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Login ke Firebase dengan kredensial Google
    final fb_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    final fb_auth.User? firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw Exception("Gagal masuk dengan Google");
    }

    final uid = firebaseUser.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    UserModel userModel;
    if (doc.exists) {
      // User sudah ada, ambil datanya
      userModel = UserModel.fromMap(doc.data()!, uid);
    } else {
      // User baru, buat data baru di Firestore
      userModel = UserModel(
        userId: uid,
        name: firebaseUser.displayName ?? 'Pengguna',
        email: firebaseUser.email ?? '',
        profileImage: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        streak: 1,
        totalMoodLogs: 0,
        xp: 50,
      );
      await _firestore.collection('users').doc(uid).set(userModel.toFirestoreMap());
    }

    // Simpan ke cache lokal
    await LocalStorageService.saveUser(userModel.toMap()..['userId'] = uid);

    return userModel;
  }
}
