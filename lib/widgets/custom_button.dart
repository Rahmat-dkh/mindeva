import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final double height;
  final double? width;
  final Gradient? gradient;
  final Color? color;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.height = 56,
    this.width,
    this.gradient,
    this.color,
    this.textColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1.0 - _controller.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: widget.isLoading ? null : _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            gradient: widget.gradient ??
                (widget.color == null
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null),
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (widget.color ?? AppColors.primary).withOpacity(isDark ? 0.2 : 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
