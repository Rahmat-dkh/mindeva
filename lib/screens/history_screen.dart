import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'journal_screen.dart';
import 'calendar_screen.dart';
import 'mood_tracker_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF0F6FF),
        body: Column(
          children: [
            // ===== BLUE PINNED HEADER =====
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0A1128), const Color(0xFF162545)]
                      : [AppColors.secondary, AppColors.primary],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Page title
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Riwayat & Statistik',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    // Tab bar (pinned, bagian dari header biru)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          labelColor: AppColors.primary,
                          unselectedLabelColor: Colors.white70,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          tabs: const [
                            Tab(text: 'Mood Harian'),
                            Tab(text: 'Jurnal Refleksi'),
                            Tab(text: 'Kalender Mood'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== TAB CONTENT =====
            const Expanded(
              child: TabBarView(
                children: [
                  MoodTrackerScreen(),
                  JournalScreen(),
                  CalendarScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

