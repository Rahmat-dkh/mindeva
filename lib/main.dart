import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/config.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/streak_provider.dart';
import 'package:flutter/foundation.dart';
import 'services/local_storage_service.dart';
import 'screens/splash_screen.dart';
import 'core/api_keys.dart'; // Tambahkan import ini

import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale data untuk format tanggal Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  if (AppConfig.useFirebase) {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: ApiKeys.firebaseApiKey,
            authDomain: ApiKeys.firebaseAuthDomain,
            projectId: ApiKeys.firebaseProjectId,
            storageBucket: ApiKeys.firebaseStorageBucket,
            messagingSenderId: ApiKeys.firebaseMessagingSenderId,
            appId: ApiKeys.firebaseAppId,
            measurementId: ApiKeys.firebaseMeasurementId,
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      print("Firebase successfully initialized");

      // Inisialisasi App Check untuk melindungi layanan Firebase secara gratis dan aman
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'), // Ganti jika pakai web app check
      );
    } catch (e) {
      print("Firebase initialization error: $e");
    }
  }

  // Inisialisasi SharedPreferences untuk offline cache
  await LocalStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Mindeva',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
