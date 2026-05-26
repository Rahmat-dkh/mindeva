import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "Track Your Mood",
      description: "Catat suasana hatimu setiap hari dengan emoji ekspresif untuk mengenali pola kesehatan emosionalmu secara konsisten.",
      icon: Icons.bubble_chart_rounded,
      gradientColors: [AppColors.primaryLight, AppColors.secondary],
    ),
    OnboardingPageData(
      title: "Understand Your Emotions",
      description: "Dapatkan analisis mendalam dari AI Gemini yang membantumu menguraikan tingkat stres, sentimen harian, dan saran personal.",
      icon: Icons.psychology_rounded,
      gradientColors: [AppColors.secondary, AppColors.primary],
    ),
    OnboardingPageData(
      title: "Heal & Grow Every Day",
      description: "Ikuti latihan pernapasan interaktif, dapatkan motivasi harian, dan pertahankan streak untuk kesehatan mental yang lebih baik.",
      icon: Icons.spa_rounded,
      gradientColors: [AppColors.primary, AppColors.primaryLight],
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Skip Button
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Lewati',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),
            
            // Onboarding Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        // Soft Illustration placeholder using containers, gradients and shadow
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: page.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: page.gradientColors.first.withOpacity(0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 96,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blueGrey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                          ),
                        ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Indicator and Navigation Button
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  CustomButton(
                    text: _currentPage == _pages.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
