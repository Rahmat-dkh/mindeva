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
                // ===== PREMIUM HERO HEADER =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(_getGreetingIcon(), color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  _getTimeBasedGreeting(),
                                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? 'Sobat Mindeva',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user?.streak ?? 0} Hari Streak',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Decorative icon
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 36),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Gamification (XP Progress Bar)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          'Lv.$currentLevel',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Progres Energi Mental',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$userXp / $nextLevelXp XP',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: levelProgress,
                                minHeight: 6,
                                color: AppColors.primary,
                                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Emojis Mood Selector Card
                Text(
                  'Bagaimana perasaanmu sekarang?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildEmojiButton('happy', '😊', AppColors.moodHappy, 'Senang'),
                        const SizedBox(width: 12),
                        _buildEmojiButton('neutral', '😐', AppColors.moodNeutral, 'Calm'),
                        const SizedBox(width: 12),
                        _buildEmojiButton('sad', '😢', AppColors.moodSad, 'Sedih'),
                        const SizedBox(width: 12),
                        _buildEmojiButton('angry', '😠', AppColors.moodAngry, 'Marah'),
                        const SizedBox(width: 12),
                        _buildEmojiButton('anxious', '😰', AppColors.moodAnxious, 'Cemas'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Quote Card
                GlassCard(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF312E81).withOpacity(0.4), const Color(0xFF1E1B4B).withOpacity(0.4)]
                        : [AppColors.primary.withOpacity(0.08), AppColors.primaryLight.withOpacity(0.08)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Afirmasi Hari Ini',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey.shade200 : Colors.blueGrey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getMoodBasedQuote(lastMood),
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Shortcuts (Breathing Exercise & Tips)
                Text(
                  'Shortcut Kesehatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildShortcutCard(
                        title: 'Latihan Napas',
                        subtitle: 'Kurangi cemas & stres',
                        icon: Icons.air_rounded,
                        color: AppColors.moodNeutral,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BreathingExerciseScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildShortcutCard(
                        title: 'Tips Wellness',
                        subtitle: 'Panduan self care',
                        icon: Icons.eco_rounded,
                        color: AppColors.moodHappy,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WellnessTipsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
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

  Widget _buildEmojiButton(String moodKey, String emoji, Color color, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => _showMoodNoteBottomSheet(moodKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.blueGrey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
              ),
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
