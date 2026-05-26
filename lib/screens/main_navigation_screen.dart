import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/streak_provider.dart';
import 'dashboard_screen.dart';
import 'mood_tracker_screen.dart';
import 'journal_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late PageController _pageController;

  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const DashboardScreen(),
      const MoodTrackerScreen(),
      const JournalScreen(),
      const CalendarScreen(),
      const ProfileScreen(),
    ];
    
    // Fetch data setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryFetchData();
    });
  }

  void _tryFetchData() {
    if (_dataFetched) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.userId;
    if (userId != null) {
      _dataFetched = true;
      Provider.of<MoodProvider>(context, listen: false).fetchMoodLogs(userId);
      Provider.of<JournalProvider>(context, listen: false).fetchJournals(userId);
      Provider.of<StreakProvider>(context, listen: false).fetchAchievements(userId);
    } else {
      // Retry setelah 500ms jika auth belum siap
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _tryFetchData();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Membuat scaffold mengalir di bawah Bottom Navigation Bar
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : AppColors.primary.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.8)
                  : Colors.white.withOpacity(0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.emoji_emotions_rounded, 'Mood'),
                  _buildNavItem(2, Icons.book_rounded, 'Jurnal'),
                  _buildNavItem(3, Icons.calendar_month_rounded, 'Kalender'),
                  _buildNavItem(4, Icons.person_rounded, 'Profil'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () => _onTabTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(
            colors: [AppColors.primary.withOpacity(isDark ? 0.25 : 0.15), AppColors.primaryLight.withOpacity(0.08)],
          ) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? Colors.grey.shade500 : Colors.blueGrey.shade400),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? Colors.grey.shade500 : Colors.blueGrey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
