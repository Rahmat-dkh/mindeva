import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/streak_provider.dart';
import '../models/mood_model.dart';
import '../widgets/glass_card.dart';
import 'breathing_screen.dart';
import 'wellness_tips_screen.dart';
import 'meditation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _noteController = TextEditingController();
  String _selectedMood = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Greeting berdasarkan waktu local
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 17) {
      return "Selamat Siang";
    } else if (hour >= 17 && hour < 20) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  // Teks Streak berdasarkan hari
  String _getStreakText(int streak) {
    if (streak == 0) return '0 Hari Streak';
    if (streak >= 100 && streak % 100 == 0) {
      return '$streak Hari Konsisten!';
    } else if (streak >= 30 && streak % 30 == 0) {
      return '${streak ~/ 30} Bulan Streak!';
    } else if (streak >= 7 && streak % 7 == 0) {
      return '${streak ~/ 7} Minggu Streak!';
    }
    return '$streak Hari Streak';
  }

  // Warna gradasi streak berdasarkan milestone
  List<Color> _getStreakGradient(int streak) {
    if (streak >= 100 && streak % 100 == 0) {
      // Kelipatan 100: emas/kuning mewah
      return const [Color(0xFFFFD700), Color(0xFFFFA500)];
    } else if (streak >= 100) {
      // 100+: ungu premium
      return const [Color(0xFF7C3AED), Color(0xFFA78BFA)];
    } else if (streak >= 30) {
      // 1 Bulan+: merah-oranye api
      return const [Color(0xFFEF4444), Color(0xFFF97316)];
    } else if (streak >= 7) {
      // 1 Minggu+: hijau emerald
      return const [Color(0xFF059669), Color(0xFF34D399)];
    }
    // Default: biru
    return const [Color(0xFF3B82F6), Color(0xFF60A5FA)];
  }

  Color _getStreakShadowColor(int streak) {
    if (streak >= 100 && streak % 100 == 0) return const Color(0xFFFFD700);
    if (streak >= 100) return const Color(0xFF7C3AED);
    if (streak >= 30) return const Color(0xFFEF4444);
    if (streak >= 7) return const Color(0xFF059669);
    return Colors.blue;
  }

  String _getStreakEmoji(int streak) {
    if (streak >= 100 && streak % 100 == 0) return '🏆';
    if (streak >= 100) return '💎';
    if (streak >= 30) return '⚡';
    if (streak >= 7) return '🌟';
    return '🔥';
  }

  Color _getStreakCheckColor(int streak) {
    final gradient = _getStreakGradient(streak);
    return gradient[0];
  }

  // Sapaan Icon
  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 17) {
      return Icons.wb_sunny_rounded;
    } else {
      return Icons.nights_stay_rounded;
    }
  }

  // Quote harian sesuai mood terakhir user
  String _getMoodBasedQuote(String? lastMood) {
    switch (lastMood) {
      case 'happy':
        return "Hari ini kamu bersinar. Sebarkan kebahagiaanmu kepada orang di sekitarmu!";
      case 'sad':
        return "Tidak apa-apa untuk tidak baik-baik saja. Berjalanlah perlahan, awan gelap akan berlalu.";
      case 'angry':
        return "Tarik napas sedalam-dalamnya. Biarkan ketegangan mereda perlahan, kamu memegang kendali.";
      case 'anxious':
        return "Rilekskan bahumu. Tarik napas perlahan... Kamu aman di sini dan sekarang.";
      case 'neutral':
        return "Hari yang damai. Luangkan waktu sejenak untuk bersyukur atas ketenangan ini.";
      default:
        return "Selamat datang di Mindeva. Mari lalui hari ini dengan penuh kesadaran diri.";
    }
  }

  // Pemicu Bottom Sheet untuk input catatan mood
  void _showMoodNoteBottomSheet(String mood) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMood = mood;
    });
    _noteController.clear();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                ? MediaQuery.of(context).viewInsets.bottom + 10 
                : MediaQuery.of(context).padding.bottom + 10,
            left: 12,
            right: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GlassCard(
                borderRadius: 28,
                blur: 15.0, // Keep blur on modal sheets
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tulis Catatan Harian',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.blueGrey.shade800,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Mood terpilih: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                            ),
                          ),
                          _buildMoodIndicatorChip(mood),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _noteController,
                          minLines: 2,
                          maxLines: 5,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.blueGrey.shade800,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Bagaimana perasaanmu? Tulis keluh kesahmu di sini untuk dianalisis oleh AI...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _saveMoodLog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Simpan & Analisis AI',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
);
}

  Widget _buildMoodIndicatorChip(String mood) {
    String emoji = '😐';
    String text = 'Netral';
    Color color = AppColors.moodNeutral;

    if (mood == 'happy') {
      emoji = '😊';
      text = 'Senang';
      color = AppColors.moodHappy;
    } else if (mood == 'sad') {
      emoji = '😢';
      text = 'Sedih';
      color = AppColors.moodSad;
    } else if (mood == 'angry') {
      emoji = '😠';
      text = 'Marah';
      color = AppColors.moodAngry;
    } else if (mood == 'anxious') {
      emoji = '😰';
      text = 'Cemas';
      color = AppColors.moodAnxious;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMoodLog() async {
    Navigator.pop(context); // Close bottom sheet
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);

    final userId = authProvider.user?.userId;
    if (userId == null) return;

    // Loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: GlassCard(
          borderRadius: 20,
          blur: 15.0, // Keep blur on dialog overlay
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'AI sedang menganalisis emosimu...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    // Save Mood
    final saved = await moodProvider.addMood(
      userId: userId,
      mood: _selectedMood,
      note: _noteController.text,
      authProvider: authProvider,
    );

    if (mounted) {
      Navigator.pop(context); // Close loading overlay
    }

    if (saved != null) {
      // Check Achievements
      final newlyUnlocked = await streakProvider.checkAndUnlockAchievements(
        userId: userId,
        currentStreak: authProvider.user?.streak ?? 1,
        totalMoodLogs: moodProvider.moodLogs.length,
        totalJournals: journalProvider.journals.length,
        authProvider: authProvider,
      );

      if (newlyUnlocked != null && mounted) {
        _showAchievementDialog(newlyUnlocked.title, newlyUnlocked.description);
      }
    }
  }

  void _showAchievementDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🏆 ', style: TextStyle(fontSize: 28)),
            Text('Pencapaian Baru!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lencana Terbuka: $title',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            const Text(
              'Bonus +100 XP ditambahkan!',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hebat!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final streakProvider = Provider.of<StreakProvider>(context);
    
    final user = authProvider.user;
    final lastMood = moodProvider.moodLogs.isNotEmpty ? moodProvider.moodLogs.first.mood : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userXp = user?.xp ?? 0;
    final currentLevel = streakProvider.getLevel(userXp);
    final levelProgress = streakProvider.getLevelProgress(userXp);
    final nextLevelXp = streakProvider.getNextLevelXp(userXp);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, AppColors.surfaceDark]
                : [const Color(0xFFE0F2FE), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== NEW HEADER =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dynamic Profile Picture / Initial
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                        border: Border.all(color: Colors.white, width: 2),
                        image: user?.profileImage != null && user!.profileImage!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(user.profileImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.profileImage == null || user!.profileImage!.isEmpty
                          ? Center(
                              child: Text(
                                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'M',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getTimeBasedGreeting()},',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user?.name ?? 'Sobat Mindeva',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.blueGrey.shade900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text(' 👋', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Yuk, rawat dirimu hari ini 💙',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada notifikasi baru.')));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Colors.blueGrey),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ===== STREAK CARD =====
                Builder(builder: (context) {
                  final streak = user?.streak ?? 0;
                  final gradientColors = _getStreakGradient(streak);
                  final shadowColor = _getStreakShadowColor(streak);
                  final streakEmoji = _getStreakEmoji(streak);
                  final checkColor = _getStreakCheckColor(streak);

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(color: shadowColor.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(streakEmoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getStreakText(streak),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pertahankan streak mu!',
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                              ),
                              const SizedBox(height: 12),
                              // Days Row (dynamic based on current weekday)
                              Builder(builder: (context) {
                                final dayLabels = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];
                                final todayIdx = DateTime.now().weekday - 1;
                                final completedDays = streak >= 7 ? todayIdx + 1 : (streak > todayIdx + 1 ? todayIdx + 1 : streak);

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: dayLabels.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    String day = entry.value;
                                    bool isCompleted = idx < completedDays;
                                    bool isToday = idx == todayIdx;
                                    return Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isCompleted ? Colors.white : Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isToday ? Colors.white : Colors.transparent,
                                          width: isToday ? 2 : 0,
                                        ),
                                      ),
                                      child: Center(
                                        child: isCompleted
                                          ? Icon(Icons.check, color: checkColor, size: 12)
                                          : Text(day, style: const TextStyle(color: Colors.white, fontSize: 10)),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // HD 3D Flame/Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Colors.white30, Colors.transparent],
                              center: Alignment(-0.3, -0.3),
                              radius: 0.8,
                            ),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 15, spreadRadius: 5),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  width: 30,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Text(streakEmoji, style: const TextStyle(fontSize: 32, shadows: [
                                Shadow(color: Colors.orangeAccent, blurRadius: 15)
                              ])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // ===== LEVEL PROGRESS CARD =====
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.star_rounded, color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lv. $currentLevel',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.blueAccent : Colors.blue.shade700),
                                      ),
                                      Text(
                                        'Progres Energi',
                                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$userXp / $nextLevelXp XP',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: levelProgress,
                                minHeight: 6,
                                color: Colors.blue,
                                backgroundColor: Colors.blue.shade100,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${nextLevelXp - userXp} XP lagi ke Level ${currentLevel + 1}',
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.card_giftcard_rounded, color: Colors.purple, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ===== MOOD SELECTOR =====
                Text(
                  'Bagaimana perasaanmu sekarang?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildEmojiButton('happy', '😊', Colors.green, 'Senang', 'Semangat')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildEmojiButton('neutral', '😐', Colors.blue, 'Calm', 'Biasa')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildEmojiButton('sad', '😢', Colors.purple, 'Sedih', 'Peluk')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildEmojiButton('angry', '😠', Colors.red, 'Marah', 'Kesal')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildEmojiButton('anxious', '😰', Colors.orange, 'Cemas', 'Gelisah')),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // ===== AFIRMASI HARI INI =====
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '"',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent, height: 1.0),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Afirmasi Hari Ini',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getMoodBasedQuote(lastMood),
                              style: TextStyle(
                                fontSize: 12, 
                                fontStyle: FontStyle.italic, 
                                color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade800, 
                                height: 1.4
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ===== REKOMENDASI UNTUKMU =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rekomendasi untukmu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.blueGrey.shade900,
                      ),
                    ),
                    const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRecommendationCard(
                        'Latihan\nPernapasan', 
                        '3-5 menit', 
                        Icons.air_rounded, 
                        Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BreathingExerciseScreen()),
                          );
                        }
                      ),
                      const SizedBox(width: 12),
                      _buildRecommendationCard(
                        'Tips Wellness', 
                        'Panduan self care', 
                        Icons.eco_rounded, 
                        Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WellnessTipsScreen()),
                          );
                        }
                      ),
                      const SizedBox(width: 12),
                      _buildRecommendationCard(
                        'Meditasi\nSingkat', 
                        '10 menit', 
                        Icons.self_improvement_rounded, 
                        Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MeditationScreen()),
                          );
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Weekly Chart Preview
                Text(
                  'Statistik Mood Mingguan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: GlassCard(
                    padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 20),
                    child: _buildWeeklyChart(moodProvider.moodLogs),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiButton(String moodKey, String emoji, Color color, String name, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedMood == moodKey;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = moodKey;
        });
        // You can still call bottom sheet here or keep it simple selection
        _showMoodNoteBottomSheet(moodKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.grey.shade800 : Colors.transparent),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.3) : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
            if (!isSelected && !isDark)
              const BoxShadow(
                color: Colors.white,
                blurRadius: 4,
                offset: Offset(-2, -2),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : (isDark ? Colors.grey.shade300 : Colors.blueGrey.shade500),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -8,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String subtitle, IconData icon, Color color, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color, height: 1.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Visualisasi chart fl_chart
  Widget _buildWeeklyChart(List<MoodModel> logs) {
    if (logs.isEmpty) {
      return const Center(child: Text('Belum ada data mood minggu ini.'));
    }

    // Mengambil data 7 hari terakhir
    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      // Cari log di tanggal yang bersangkutan
      final logsOnDay = logs.where((log) =>
          log.createdAt.year == day.year &&
          log.createdAt.month == day.month &&
          log.createdAt.day == day.day);

      double moodVal = 0.0; // Default kosong / netral
      Color barColor = Colors.grey.shade400;

      if (logsOnDay.isNotEmpty) {
        final primaryMood = logsOnDay.first.mood;
        if (primaryMood == 'happy') {
          moodVal = 5.0;
          barColor = AppColors.moodHappy;
        } else if (primaryMood == 'neutral') {
          moodVal = 4.0;
          barColor = AppColors.moodNeutral;
        } else if (primaryMood == 'anxious') {
          moodVal = 3.0;
          barColor = AppColors.moodAnxious;
        } else if (primaryMood == 'sad') {
          moodVal = 2.0;
          barColor = AppColors.moodSad;
        } else if (primaryMood == 'angry') {
          moodVal = 1.0;
          barColor = AppColors.moodAngry;
        }
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: moodVal == 0 ? 0.5 : moodVal,
              color: barColor,
              width: 14,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5.0,
                color: Colors.grey.withOpacity(0.08),
              ),
            ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final daysOfWeek = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final dateIdx = (DateTime.now().subtract(Duration(days: 6 - value.toInt())).weekday - 1) % 7;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    daysOfWeek[dateIdx],
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }
}
