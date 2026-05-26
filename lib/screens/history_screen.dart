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
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFE0F2FE),
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  tabs: const [
                    Tab(text: 'Mood Harian'),
                    Tab(text: 'Jurnal Refleksi'),
                    Tab(text: 'Kalender Mood'),
                  ],
                ),
              ),
              
              // Tab Content
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
      ),
    );
  }
}
