import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood_model.dart';
import '../widgets/glass_card.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _editNoteController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _editNoteController.dispose();
    super.dispose();
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'happy': return '😊';
      case 'sad': return '😢';
      case 'angry': return '😠';
      case 'anxious': return '😰';
      default: return '😐';
    }
  }

  String _getMoodName(String mood) {
    switch (mood) {
      case 'happy': return 'Senang';
      case 'sad': return 'Sedih';
      case 'angry': return 'Marah';
      case 'anxious': return 'Cemas';
      default: return 'Netral';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy': return AppColors.moodHappy;
      case 'sad': return AppColors.moodSad;
      case 'angry': return AppColors.moodAngry;
      case 'anxious': return AppColors.moodAnxious;
      default: return AppColors.moodNeutral;
    }
  }

  void _showAIAnalysisDialog(MoodModel log) {
    final analysis = log.aiAnalysis;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodColor = _getMoodColor(log.mood);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.surfaceDark, const Color(0xFF1E1B4B)]
                    : [Colors.white, const Color(0xFFEEF2FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analisis AI Mindeva',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.blueGrey.shade800,
                              ),
                            ),
                            Text(
                              'Wawasan mendalam tentang emosimu',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.grey.shade500),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (analysis == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Analisis AI belum selesai dibuat untuk entri ini.',
                          style: TextStyle(color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else ...[
                    // Stress Level
                    _buildAnalysisSection(
                      isDark: isDark,
                      icon: Icons.bolt_rounded,
                      label: 'Tingkat Stres',
                      child: Row(
                        children: List.generate(5, (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            index < analysis.stressLevel ? Icons.offline_bolt_rounded : Icons.offline_bolt_outlined,
                            color: index < analysis.stressLevel ? Colors.orangeAccent : Colors.grey.shade400,
                            size: 22,
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Emotional State
                    _buildAnalysisSection(
                      isDark: isDark,
                      icon: Icons.psychology_rounded,
                      label: 'Kondisi Emosional',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: moodColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          analysis.emotionalState,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: moodColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Motivation
                    _buildAnalysisSection(
                      isDark: isDark,
                      icon: Icons.format_quote_rounded,
                      label: 'Afirmasi AI',
                      child: Text(
                        '"${analysis.motivation}"',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13.5,
                          height: 1.5,
                          color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Recommendations
                    _buildAnalysisSection(
                      isDark: isDark,
                      icon: Icons.eco_rounded,
                      label: 'Saran Self Care',
                      child: Column(
                        children: analysis.recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4, right: 8),
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisSection({
    required bool isDark,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                  color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  void _showEditMoodDialog(MoodModel log) {
    HapticFeedback.lightImpact();
    _editNoteController.text = log.note;
    String selectedMood = log.mood;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.surfaceDark, AppColors.backgroundDark]
                        : [Colors.white, const Color(0xFFEEF2FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Edit Catatan Mood',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.blueGrey.shade800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Mood selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['happy', 'neutral', 'sad', 'angry', 'anxious'].map((key) {
                        final isSelected = key == selectedMood;
                        final color = _getMoodColor(key);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setSheetState(() => selectedMood = key);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Text(_getMoodEmoji(key), style: const TextStyle(fontSize: 26)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Text field
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white70,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: _editNoteController,
                        maxLines: 3,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.blueGrey.shade800,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Perbarui keluh kesahmu...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final moodProvider = Provider.of<MoodProvider>(context, listen: false);
                          final userId = authProvider.user?.userId;
                          if (userId != null) {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                            );
                            await moodProvider.updateMood(
                              userId: userId,
                              moodId: log.moodId,
                              mood: selectedMood,
                              note: _editNoteController.text,
                            );
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
            },
          ),
        );
      },
    );
  }

  void _confirmDeleteMood(MoodModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Log Mood', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus catatan mood ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final moodProvider = Provider.of<MoodProvider>(context, listen: false);
              final userId = authProvider.user?.userId;
              if (userId != null) {
                Navigator.pop(context);
                await moodProvider.deleteMood(userId, log.moodId);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF1E1B4B)]
                : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== PREMIUM HEADER =====
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riwayat Emosi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.blueGrey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Perjalanan perasaanmu',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mood stat badge
                    if (moodProvider.moodLogs.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${moodProvider.moodLogs.length} Entri',
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
              const SizedBox(height: 16),

              // Mood Log List
              Expanded(
                child: moodProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : moodProvider.moodLogs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                            itemCount: moodProvider.moodLogs.length,
                            itemBuilder: (context, index) {
                              final log = moodProvider.moodLogs[index];
                              return _buildMoodLogCard(log, index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              size: 56,
              color: isDark ? Colors.grey.shade500 : Colors.blueGrey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada riwayat mood',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Mulai catat moodmu dari halaman Beranda dan pantau perjalanan emosimu di sini.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.grey.shade500 : Colors.blueGrey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodLogCard(MoodModel log, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emoji = _getMoodEmoji(log.mood);
    final moodName = _getMoodName(log.mood);
    final moodColor = _getMoodColor(log.mood);
    final formattedDate = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(log.createdAt);
    final formattedTime = DateFormat('HH:mm').format(log.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: moodColor, width: 6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  // Mood name & Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moodName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.blueGrey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$formattedTime • $formattedDate',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      _buildIconBtn(Icons.edit_outlined, Colors.blueGrey.shade400, () => _showEditMoodDialog(log)),
                      const SizedBox(width: 8),
                      _buildIconBtn(Icons.delete_outline_rounded, Colors.redAccent.withOpacity(0.7), () => _confirmDeleteMood(log)),
                    ],
                  ),
                ],
              ),
              
              if (log.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.note,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 10),
              // AI Analysis Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showAIAnalysisDialog(log);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: moodColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: moodColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Analisis AI',
                        style: TextStyle(
                          color: moodColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
