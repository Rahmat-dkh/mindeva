import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class WellnessTipsScreen extends StatelessWidget {
  const WellnessTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<WellnessTipData> tips = [
      WellnessTipData(
        category: "Self Healing",
        title: "Seni Melepaskan Masa Lalu",
        description: "Menyembuhkan luka emosional lama dimulai dengan penerimaan diri. Tulis jurnal untuk mengeluarkan emosi negatif dan berdamai dengan masa lalu secara perlahan.",
        icon: Icons.favorite_rounded,
        color: AppColors.moodHappy,
      ),
      WellnessTipData(
        category: "Stress Management",
        title: "Metode Pomodoro untuk Istirahat Mental",
        description: "Saat tertekan oleh tugas kuliah atau pekerjaan, gunakan metode 25 menit fokus dan 5 menit istirahat. Gunakan 5 menit tersebut untuk menjauh dari layar, meregangkan tubuh, dan memejamkan mata.",
        icon: Icons.bolt_rounded,
        color: AppColors.moodAnxious,
      ),
      WellnessTipData(
        category: "Relaxation Guide",
        title: "Teknik Grounding 5-4-3-2-1",
        description: "Saat dilanda kepanikan atau cemas berlebih, sebutkan di dalam hati: 5 benda yang dilihat, 4 benda yang diraba, 3 suara yang didengar, 2 aroma yang dicium, dan 1 rasa yang dikecap.",
        icon: Icons.spa_rounded,
        color: AppColors.moodNeutral,
      ),
      WellnessTipData(
        category: "Positive Affirmations",
        title: "Menanamkan Afirmasi di Pagi Hari",
        description: "Ucapkan di depan cermin sebelum memulai hari: 'Saya berharga. Usaha saya hari ini cukup. Saya aman dan memegang kendali atas ketenangan pikiran saya sendiri.'",
        icon: Icons.auto_awesome_rounded,
        color: AppColors.primary,
      ),
      WellnessTipData(
        category: "Self Care",
        title: "Pentingnya Digital Detox Sebelum Tidur",
        description: "Matikan semua notifikasi sosial media minimal 45 menit sebelum tidur. Cahaya biru layar menghambat produksi melatonin, hormon pemicu rasa rileks dan ngantuk alami.",
        icon: Icons.nights_stay_rounded,
        color: AppColors.moodSad,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips Wellness & Ketenangan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.blueGrey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag & Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tip.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tip.category,
                              style: TextStyle(
                                color: tip.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Icon(tip.icon, color: tip.color, size: 22),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blueGrey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        tip.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class WellnessTipData {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  WellnessTipData({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
