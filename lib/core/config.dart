import '../repositories/auth_repository.dart';
import '../repositories/mood_repository.dart';
import '../repositories/journal_repository.dart';

class AppConfig {
  // Firebase aktif — google-services.json sudah dikonfigurasi (project: mind-deva)
  static const bool useFirebase = true;

  // Resolusi Repositori berdasarkan konfigurasi Firebase
  static AuthRepository get authRepository {
    return useFirebase ? FirebaseAuthRepository() : MockAuthRepository();
  }

  static MoodRepository get moodRepository {
    return useFirebase ? FirebaseMoodRepository() : MockMoodRepository();
  }

  static JournalRepository get journalRepository {
    return useFirebase ? FirebaseJournalRepository() : MockJournalRepository();
  }
}
