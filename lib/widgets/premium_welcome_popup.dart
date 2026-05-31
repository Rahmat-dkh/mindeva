import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../screens/premium_screen.dart';

/// Menampilkan popup notifikasi premium setelah login.
/// Dipanggil sekali dengan `showPremiumWelcomePopup(context)`.
Future<void> showPremiumWelcomePopup(BuildContext context) async {
  HapticFeedback.mediumImpact();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'premium_popup',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => const _PremiumWelcomeDialog(),
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

class _PremiumWelcomeDialog extends StatefulWidget {
  const _PremiumWelcomeDialog();

  @override
  State<_PremiumWelcomeDialog> createState() => _PremiumWelcomeDialogState();
}

class _PremiumWelcomeDialogState extends State<_PremiumWelcomeDialog>
    with TickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late AnimationController _sparkleCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.88,
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0D1B3E),
                      const Color(0xFF0A2560),
                      const Color(0xFF0D1B3E),
                    ]
                  : [
                      const Color(0xFF0077B6),
                      const Color(0xFF023E8A),
                      const Color(0xFF03045E),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                blurRadius: 60,
                spreadRadius: -5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // ── Sparkle particles di background ──
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _sparkleCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _SparklePainter(_sparkleCtrl.value),
                    ),
                  ),
                ),

                // ── Shimmer bar di atas ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (_, __) => Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(_shimmerAnim.value - 1, 0),
                          end: Alignment(_shimmerAnim.value + 1, 0),
                          colors: [
                            Colors.transparent,
                            const Color(0xFFFFD700).withOpacity(0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Konten utama ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Crown icon dengan glow
                      _buildCrownIcon(),
                      const SizedBox(height: 20),

                      // Badge "EKSKLUSIF"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFFFFD700),
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'PENAWARAN EKSKLUSIF',
                              style: TextStyle(
                                color: const Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Judul
                      const Text(
                        'Upgrade ke\nMindeva Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        'Buka akses penuh ke semua fitur premium\ndan tingkatkan kesehatan mentalmu! 🧠✨',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Feature list
                      _buildFeatureList(),
                      const SizedBox(height: 26),

                      // CTA Button
                      _buildCTAButton(context),
                      const SizedBox(height: 14),

                      // Dismiss link
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Nanti saja',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrownIcon() {
    return AnimatedBuilder(
      animation: _sparkleCtrl,
      builder: (_, child) {
        final bounce = sin(_sparkleCtrl.value * 2 * pi) * 4;
        return Transform.translate(
          offset: Offset(0, bounce),
          child: child,
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.workspace_premium_rounded,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      (Icons.psychology_alt_rounded, 'Analisis AI Mood Tanpa Batas'),
      (Icons.menu_book_rounded, 'Jurnal Tak Terbatas + Wawasan'),
      (Icons.spa_rounded, 'Meditasi & Breathing Premium'),
      (Icons.support_agent_rounded, 'Konsultasi Psikolog Prioritas'),
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                      ),
                    ),
                    child: Icon(f.$1, color: const Color(0xFFFFD700), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f.$2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF34D399),
                    size: 18,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (_, __) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment(_shimmerAnim.value - 1, -0.5),
                end: Alignment(_shimmerAnim.value + 1, 0.5),
                colors: const [
                  Color(0xFFFFD700),
                  Color(0xFFFFA500),
                  Color(0xFFFFD700),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFF1A1A00),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Coba Premium Sekarang',
                  style: TextStyle(
                    color: Color(0xFF1A1A00),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Custom Painter untuk efek sparkle/bintang ──
class _SparklePainter extends CustomPainter {
  final double progress;
  _SparklePainter(this.progress);

  static final _rng = Random(42);
  static final _particles = List.generate(18, (i) {
    return (
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: _rng.nextDouble() * 3 + 1.0,
      speed: _rng.nextDouble() * 0.4 + 0.1,
      phase: _rng.nextDouble(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final alpha = ((sin((progress + p.phase) * 2 * pi) + 1) / 2);
      paint.color = const Color(0xFFFFD700).withOpacity(alpha * 0.6);

      final x = p.x * size.width;
      final y = ((p.y + progress * p.speed) % 1.0) * size.height;

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}
