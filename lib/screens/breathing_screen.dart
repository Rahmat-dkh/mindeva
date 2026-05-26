import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  Timer? _countdownTimer;
  Timer? _phaseTimer;
  
  int _totalSecondsRemaining = 300; // 5 menit default
  bool _isActive = false;
  String _currentPhase = 'Siap untuk memulai?';
  String _instructionText = 'Ketuk tombol Mulai untuk memulai sesi relaksasi.';
  int _phaseCount = 0; // 0 = Inhale, 1 = Hold, 2 = Exhale

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.85).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phaseTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isActive = true;
      _totalSecondsRemaining = 300;
      _phaseCount = 0;
    });

    _startTimers();
    _runBreathingCycle();
  }

  void _pauseSession() {
    setState(() {
      _isActive = false;
      _currentPhase = 'Sesi Dijeda';
      _instructionText = 'Ketuk Mulai Kembali untuk melanjutkan relaksasi.';
    });

    _countdownTimer?.cancel();
    _phaseTimer?.cancel();
    _animationController.stop();
  }

  void _startTimers() {
    // Timer Hitung Mundur Total Sesi
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSecondsRemaining > 0) {
        setState(() {
          _totalSecondsRemaining--;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _completeSession() {
    _countdownTimer?.cancel();
    _phaseTimer?.cancel();
    _animationController.reset();

    setState(() {
      _isActive = false;
      _currentPhase = 'Sesi Selesai';
      _instructionText = 'Luar biasa! Pikiranmu kini lebih tenang dan jernih.';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🌸 ', style: TextStyle(fontSize: 24)),
            Text('Relaksasi Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Anda telah menyelesaikan 5 menit latihan pernapasan dengan baik. Pikiran Anda kini lebih tenang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terima Kasih', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _runBreathingCycle() {
    if (!_isActive) return;

    if (_phaseCount == 0) {
      // 1. INHALE (4 detik)
      setState(() {
        _currentPhase = 'Tarik Napas';
        _instructionText = 'Tarik napas perlahan lewat hidung Anda... Rasakan ketenangan masuk.';
      });
      _animationController.forward(); // Animasi lingkaran membesar

      _phaseTimer = Timer(const Duration(seconds: 4), () {
        if (_isActive) {
          setState(() {
            _phaseCount = 1;
          });
          _runBreathingCycle();
        }
      });
    } else if (_phaseCount == 1) {
      // 2. HOLD (4 detik)
      setState(() {
        _currentPhase = 'Tahan';
        _instructionText = 'Tahan napas Anda... Rilekskan pikiran dan bahu Anda.';
      });
      // Animasi diam di ukuran penuh

      _phaseTimer = Timer(const Duration(seconds: 4), () {
        if (_isActive) {
          setState(() {
            _phaseCount = 2;
          });
          _runBreathingCycle();
        }
      });
    } else {
      // 3. EXHALE (4 detik)
      setState(() {
        _currentPhase = 'Hembuskan';
        _instructionText = 'Hembuskan napas perlahan lewat mulut... Lepaskan semua beban stres Anda.';
      });
      _animationController.reverse(); // Animasi lingkaran mengecil

      _phaseTimer = Timer(const Duration(seconds: 4), () {
        if (_isActive) {
          setState(() {
            _phaseCount = 0;
          });
          _runBreathingCycle();
        }
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan Pernapasan', style: TextStyle(fontWeight: FontWeight.bold)),
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
                ? [AppColors.backgroundDark, const Color(0xFF0F172A)]
                : [const Color(0xFFE0F2FE), const Color(0xFFF8FAFC)], // Soft Blue/White
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Timer Display
              Column(
                children: [
                  Text(
                    _formatDuration(_totalSecondsRemaining),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: isDark ? Colors.white : Colors.blueGrey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'WAKTU TERSISA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                    ),
                  ),
                ],
              ),

              // Animated Breathing Circles
              Center(
                child: SizedBox(
                  height: 250, // Memberikan ruang tetap agar tidak overflow saat animasi membesar
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Pulsing Ring
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.moodNeutral.withOpacity(0.08 * _opacityAnimation.value),
                                border: Border.all(
                                  color: AppColors.moodNeutral.withOpacity(0.25 * _opacityAnimation.value),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Inner Animated circle
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.moodNeutral.withOpacity(_opacityAnimation.value),
                                    AppColors.moodNeutral.withOpacity(_opacityAnimation.value - 0.2),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.moodNeutral.withOpacity(0.25 * _opacityAnimation.value),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _currentPhase,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Instruction Text Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.spa_rounded, color: AppColors.moodNeutral, size: 24),
                      const SizedBox(height: 10),
                      Text(
                        _instructionText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isActive)
                    ElevatedButton.icon(
                      onPressed: _startSession,
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: const Text('Mulai Relaksasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _pauseSession,
                      icon: const Icon(Icons.pause_rounded, color: Colors.white),
                      label: const Text('Jeda Sesi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.moodAnxious,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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
