import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.borderColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
