import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 0.0,
    this.opacity = 0.6,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContainer = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E293B).withOpacity(opacity),
                      const Color(0xFF0F172A).withOpacity(opacity - 0.1),
                    ]
                  : [
                      Colors.white.withOpacity(opacity + 0.1),
                      Colors.white.withOpacity(opacity - 0.2),
                    ],
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
      ),
      child: child,
    );

    if (blur <= 0.0) {
      return cardContainer;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: cardContainer,
      ),
    );
  }
}
