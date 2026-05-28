import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;

  Timer? _countdownTimer;
  int _selectedDuration = 600; // 10 menit default (dalam detik)
  int _remainingSeconds = 600;
  bool _isActive = false;
  bool _isCompleted = false;
  int _selectedSessionIndex = 0;

  final List<Map<String, dynamic>> _sessions = [
    {
      'title': 'Kesadaran Napas',
      'duration': 600,
      'icon': Icons.air_rounded,
      'color': const Color(0xFF6366F1),
      'description': 'Fokuskan perhatian pada setiap tarikan dan hembusan napas.',
      'steps': [
        'Duduk nyaman dengan punggung tegak',
        'Tutup mata perlahan',
        'Rasakan napas masuk melalui hidung',
        'Rasakan napas keluar melalui mulut',
        'Jika pikiran mengembara, kembalikan ke napas',
        'Lanjutkan dengan lembut tanpa menghakimi diri',
      ],
    },
    {
      'title': 'Body Scan',
      'duration': 480,
      'icon': Icons.accessibility_new_rounded,
      'color': const Color(0xFF0EA5E9),
      'description': 'Pindai tubuh dari ujung kepala hingga ujung kaki.',
      'steps': [
        'Berbaring atau duduk nyaman',
        'Mulai dari bagian atas kepala',
        'Rasakan sensasi di wajah dan rahang',
        'Turun ke bahu dan leher',
        'Rasakan tangan dan jari-jari',
        'Lanjutkan ke perut, kaki, hingga ujung jari kaki',
      ],
    },
    {
      'title': 'Meditasi Cinta Kasih',
      'duration': 300,
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFF43F5E),
      'description': 'Kirimkan cinta dan kebaikan kepada diri sendiri dan orang lain.',
      'steps': [
        'Duduk nyaman, tutup mata',
        'Ucapkan dalam hati: "Semoga aku bahagia"',
        'Ucapkan: "Semoga aku sehat"',
        'Pikirkan orang yang kamu sayangi',
        'Ucapkan: "Semoga mereka bahagia"',
        'Sebarkan kebaikan ke seluruh makhluk',
      ],
    },
    {
      'title': 'Visualisasi Alam',
      'duration': 420,
      'icon': Icons.landscape_rounded,
      'color': const Color(0xFF10B981),
      'description': 'Bayangkan dirimu berada di alam yang tenang dan damai.',
      'steps': [
        'Tutup mata dan tarik napas dalam',
        'Bayangkan danau jernih yang tenang',
        'Rasakan angin lembut menerpa wajahmu',
        'Dengarkan suara kicauan burung',
        'Rasakan hangatnya sinar matahari',
        'Biarkan ketenangan alam meresap ke dalam dirimu',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _startSession() {
    final session = _sessions[_selectedSessionIndex];
    setState(() {
      _selectedDuration = session['duration'] as int;
      _remainingSeconds = _selectedDuration;
      _isActive = true;
      _isCompleted = false;
    });
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _pauseSession() {
    setState(() {
      _isActive = false;
    });
    _countdownTimer?.cancel();
    _pulseController.stop();
    _rotateController.stop();
  }

  void _resumeSession() {
    setState(() {
      _isActive = true;
    });
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _resetSession() {
    _countdownTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    _rotateController.stop();
    _rotateController.reset();
    setState(() {
      _isActive = false;
      _isCompleted = false;
      _remainingSeconds = _sessions[_selectedSessionIndex]['duration'] as int;
    });
  }

  void _completeSession() {
    _countdownTimer?.cancel();
    _pulseController.stop();
    _rotateController.stop();
    setState(() {
      _isActive = false;
      _isCompleted = true;
    });
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds / 60).floor();
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = _sessions[_selectedSessionIndex];
    final sessionColor = session['color'] as Color;
    final progress = _selectedDuration > 0
        ? (_selectedDuration - _remainingSeconds) / _selectedDuration
        : 0.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                : [sessionColor.withOpacity(0.08), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : Colors.blueGrey.shade800),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Meditasi Singkat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blueGrey.shade900,
                        ),
                      ),
                    ),
                    Icon(Icons.self_improvement_rounded, color: sessionColor, size: 28),
                  ],
                ),
              ),

              Expanded(
                child: _isActive || (_remainingSeconds < _selectedDuration && !_isCompleted)
                    ? _buildActiveSession(isDark, session, sessionColor, progress)
                    : _isCompleted
                        ? _buildCompletedView(isDark, session, sessionColor)
                        : _buildSessionPicker(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========= SESSION PICKER VIEW =========
  Widget _buildSessionPicker(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Sesi Meditasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.blueGrey.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Temukan ketenangan dalam beberapa menit saja',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500),
          ),
          const SizedBox(height: 24),

          // Session Cards
          ...List.generate(_sessions.length, (index) {
            final s = _sessions[index];
            final sColor = s['color'] as Color;
            final isSelected = _selectedSessionIndex == index;
            final duration = s['duration'] as int;
            final minutes = (duration / 60).floor();

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSessionIndex = index;
                  _remainingSeconds = s['duration'] as int;
                  _selectedDuration = s['duration'] as int;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? sColor : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? sColor.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                      blurRadius: isSelected ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: sColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(s['icon'] as IconData, color: sColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.blueGrey.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: sColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$minutes min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: sColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // START BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: _sessions[_selectedSessionIndex]['color'] as Color,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 6,
                shadowColor: (_sessions[_selectedSessionIndex]['color'] as Color).withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Mulai Meditasi',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========= ACTIVE SESSION VIEW =========
  Widget _buildActiveSession(bool isDark, Map<String, dynamic> session, Color sessionColor, double progress) {
    final steps = session['steps'] as List<String>;
    // Show the step based on progress
    final currentStepIdx = (progress * steps.length).floor().clamp(0, steps.length - 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Timer
        Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w300,
            letterSpacing: 4,
            color: isDark ? Colors.white : Colors.blueGrey.shade800,
          ),
        ),

        // Animated Circle
        SizedBox(
          height: 260,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Transform.scale(
                    scale: _pulseAnimation.value * 1.1,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: sessionColor.withOpacity(0.15), width: 2),
                      ),
                    ),
                  ),
                  // Middle ring
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sessionColor.withOpacity(0.08),
                        border: Border.all(color: sessionColor.withOpacity(0.2), width: 1.5),
                      ),
                    ),
                  ),
                  // Inner circle with progress
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: sessionColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(sessionColor),
                    ),
                  ),
                  // Center icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [sessionColor.withOpacity(0.25), sessionColor.withOpacity(0.08)],
                      ),
                    ),
                    child: Icon(session['icon'] as IconData, color: sessionColor, size: 40),
                  ),
                ],
              );
            },
          ),
        ),

        // Current Step
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  session['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: sessionColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  steps[currentStepIdx],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(steps.length, (i) {
                    return Container(
                      width: i == currentStepIdx ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= currentStepIdx ? sessionColor : sessionColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset
            GestureDetector(
              onTap: _resetSession,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.refresh_rounded, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, size: 24),
              ),
            ),
            const SizedBox(width: 24),
            // Pause/Resume
            GestureDetector(
              onTap: _isActive ? _pauseSession : _resumeSession,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sessionColor,
                  boxShadow: [
                    BoxShadow(color: sessionColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Icon(
                  _isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Skip to end
            GestureDetector(
              onTap: _completeSession,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.skip_next_rounded, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========= COMPLETED VIEW =========
  Widget _buildCompletedView(bool isDark, Map<String, dynamic> session, Color sessionColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sessionColor.withOpacity(0.12),
              ),
              child: Icon(Icons.check_circle_rounded, color: sessionColor, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Sesi Selesai! 🎉',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kamu telah menyelesaikan sesi "${session['title']}".\nPikiranmu kini lebih tenang dan fokus.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sessionColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Ulangi atau Pilih Sesi Lain',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Kembali ke Beranda',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: sessionColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
