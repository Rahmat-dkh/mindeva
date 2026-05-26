import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/mood_provider.dart';
import '../models/journal_model.dart';
import '../services/gemini_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedEmotion = 'neutral';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Pilih Tanggal Filter
  Future<void> _selectFilterDate() async {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final selected = await showDatePicker(
      context: context,
      initialDate: journalProvider.selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected != null) {
      journalProvider.setFilterDate(selected);
    }
  }

  // Tambah/Edit Jurnal di Halaman Baru
  void _openJournalComposer({JournalModel? existingJournal}) {
    final isEdit = existingJournal != null;
    if (isEdit) {
      _titleController.text = existingJournal.title;
      _contentController.text = existingJournal.content;
      _selectedEmotion = existingJournal.emotion;
    } else {
      _titleController.clear();
      _contentController.clear();
      _selectedEmotion = 'neutral';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setComposerState) {
            return Scaffold(
              backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFFAFAFA),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Text(isEdit ? 'Edit Jurnal' : 'Tulis Jurnal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.blueGrey.shade800)),
                iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.blueGrey.shade800),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextButton.icon(
                      icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                      label: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _saveJournalEntry(existingJournal),
                    ),
                  ),
                ],
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark 
                      ? [AppColors.backgroundDark, const Color(0xFF1E1B4B)]
                      : [const Color(0xFFFAFAFA), const Color(0xFFEEF2FF)],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood selector
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bagaimana perasaanmu saat ini?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildComposerMoodEmoji('happy', '😊', _selectedEmotion, (key) => setComposerState(() => _selectedEmotion = key)),
                                _buildComposerMoodEmoji('neutral', '😐', _selectedEmotion, (key) => setComposerState(() => _selectedEmotion = key)),
                                _buildComposerMoodEmoji('sad', '😢', _selectedEmotion, (key) => setComposerState(() => _selectedEmotion = key)),
                                _buildComposerMoodEmoji('angry', '😠', _selectedEmotion, (key) => setComposerState(() => _selectedEmotion = key)),
                                _buildComposerMoodEmoji('anxious', '😰', _selectedEmotion, (key) => setComposerState(() => _selectedEmotion = key)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Title Input
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blueGrey.shade900,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Judul refleksi...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 24, fontWeight: FontWeight.bold),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      
                      Container(
                        width: 60,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Content Input
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        minLines: 15,
                        style: TextStyle(
                          fontSize: 15, 
                          height: 1.8,
                          color: isDark ? Colors.grey.shade200 : Colors.blueGrey.shade800,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tuliskan pemikiran, perasaan, atau peristiwa hari ini secara mendalam...\n\nAI Konselor akan otomatis mendeteksi sentimen dan memberikan wawasan khusus untukmu.',
                          hintStyle: TextStyle(color: Colors.grey.shade400, height: 1.6),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 100), // Extra scroll space
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComposerMoodEmoji(String moodKey, String emoji, String selectedKey, Function(String) onTap) {
    final isSelected = moodKey == selectedKey;
    return GestureDetector(
      onTap: () => onTap(moodKey),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }

  Future<void> _saveJournalEntry(JournalModel? existing) async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul dan isi jurnal tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    final userId = authProvider.user?.userId;
    if (userId == null) return;

    Navigator.pop(context); // Close composer screen

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'AI sedang menganalisis jurnalmu...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    JournalModel? saved;
    if (existing != null) {
      await journalProvider.updateJournal(
        userId: userId,
        journalId: existing.journalId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        emotion: _selectedEmotion,
      );
      saved = existing; // Placeholder
    } else {
      saved = await journalProvider.addJournal(
        userId: userId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        manualEmotion: _selectedEmotion,
        authProvider: authProvider,
      );
    }

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

  // Tampilkan Jurnal Detail Popup dengan Solusi AI
  void _viewJournalDetail(JournalModel journal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(journal.createdAt);
    List<String> solutions = [];
    bool isLoadingSolution = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      journal.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formattedDate, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    const SizedBox(height: 14),
                    Text(
                      journal.content,
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                    const Divider(height: 32),

                    // AI Affirmation
                    if (journal.aiAnalysis != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Afirmasi AI:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.grey.shade200 : Colors.blueGrey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${journal.aiAnalysis!.affirmation}"',
                        style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade800),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text('Sentimen: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          _buildSentimentBadge(journal.aiAnalysis!.sentiment),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Tombol Minta Solusi AI
                    if (solutions.isEmpty && !isLoadingSolution)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 18),
                          label: const Text('Minta Solusi dari AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            setDialogState(() => isLoadingSolution = true);
                            final result = await GeminiService.getJournalSolution(journal.title, journal.content);
                            setDialogState(() {
                              solutions = result;
                              isLoadingSolution = false;
                            });
                          },
                        ),
                      ),

                    // Loading indicator
                    if (isLoadingSolution)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: 10),
                              Text('AI sedang menyusun solusi untukmu...', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),

                    // Solusi AI result
                    if (solutions.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.08), AppColors.primaryLight.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Solusi & Langkah Nyata',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...solutions.asMap().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: isDark ? Colors.grey.shade200 : Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close view
                    _openJournalComposer(existingJournal: journal);
                  },
                  child: const Text('Edit Jurnal'),
                ),
                TextButton(
                  onPressed: () => _confirmDeleteJournal(journal),
                  child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSentimentBadge(String sentiment) {
    Color color = Colors.grey;
    if (sentiment.toLowerCase().contains('posi')) {
      color = AppColors.moodHappy;
    } else if (sentiment.toLowerCase().contains('nega')) {
      color = AppColors.moodAngry;
    } else {
      color = AppColors.moodNeutral;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sentiment,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  void _confirmDeleteJournal(JournalModel journal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jurnal', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus jurnal ini secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final journalProvider = Provider.of<JournalProvider>(context, listen: false);
              final userId = authProvider.user?.userId;
              
              if (userId != null) {
                Navigator.pop(context); // Close confirm
                Navigator.pop(context); // Close view details popup
                await journalProvider.deleteJournal(userId, journal.journalId);
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
    final journalProvider = Provider.of<JournalProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== PREMIUM HEADER =====
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jurnal Refleksi',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.blueGrey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ruang jujurmu untuk menulis & bertumbuh',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (journalProvider.selectedFilterDate != null)
                          GestureDetector(
                            onTap: () => journalProvider.clearFilters(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.filter_alt_off_rounded, color: Colors.redAccent, size: 20),
                            ),
                          ),
                        if (journalProvider.selectedFilterDate != null) const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _selectFilterDate,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : AppColors.primary.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => journalProvider.search(val),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.blueGrey.shade800,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari catatan jurnal...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                journalProvider.search('');
                              },
                              child: Icon(Icons.clear, color: Colors.grey.shade400, size: 18),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              if (journalProvider.selectedFilterDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                  child: Chip(
                    label: Text(
                      'Filter: ${DateFormat('dd MMMM yyyy').format(journalProvider.selectedFilterDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () => journalProvider.clearFilters(),
                  ),
                ),

              // Journal Entries List
              Expanded(
                child: journalProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : journalProvider.journals.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                            itemCount: journalProvider.journals.length,
                            itemBuilder: (context, index) {
                              final journal = journalProvider.journals[index];
                              return _buildJournalCard(journal);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100), // Keep it above floating nav bar
        child: FloatingActionButton(
          onPressed: () => _openJournalComposer(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          borderRadius: 24,
          blur: 15.0, // Maintain premium blur on empty state card
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum Ada Jurnal Refleksi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tulis apa yang kamu rasakan, alami, atau syukuri hari ini. AI akan menganalisis jurnalmu untuk memberikan dukungan psikologis personal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openJournalComposer(),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Tulis Jurnal Pertama',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalCard(JournalModel journal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String emoji = '😐';
    Color moodColor = AppColors.moodNeutral;
    if (journal.emotion == 'happy') { emoji = '😊'; moodColor = AppColors.moodHappy; }
    else if (journal.emotion == 'sad') { emoji = '😢'; moodColor = AppColors.moodSad; }
    else if (journal.emotion == 'angry') { emoji = '😠'; moodColor = AppColors.moodAngry; }
    else if (journal.emotion == 'anxious') { emoji = '😰'; moodColor = AppColors.moodAnxious; }

    final formattedDate = DateFormat('dd MMM, yyyy').format(journal.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => _viewJournalDetail(journal),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(color: moodColor, width: 5),
              top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
              right: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
              bottom: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
            ),
            boxShadow: [
              BoxShadow(color: moodColor.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: title + emoji
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journal.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.blueGrey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Content preview
              Text(
                journal.content,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // AI Tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: journal.aiAnalysis != null
                    ? journal.aiAnalysis!.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        )).toList()
                    : [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('#Refleksi', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

