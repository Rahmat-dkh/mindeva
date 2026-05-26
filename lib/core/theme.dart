import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Palet Warna Ocean Blue (Berdasarkan Logo Baru)
  static const Color primary = Color(0xFF0077B6);      // Ocean Blue
  static const Color primaryLight = Color(0xFF00B4D8); // Vivid Cyan
  static const Color secondary = Color(0xFF03045E);    // Deep Navy Blue
  static const Color backgroundLight = Color(0xFFF8FAFC); // Light Gray
  static const Color surfaceLight = Color(0xFFE0F2FE);    // Light Sky Blue
  
  // Warna Emosi
  static const Color moodHappy = Color(0xFF34D399);    // Green
  static const Color moodNeutral = Color(0xFF38BDF8);  // Blue (Calm)
  static const Color moodSad = Color(0xFF94A3B8);      // Grey
  static const Color moodAngry = Color(0xFFF87171);    // Red
  static const Color moodAnxious = Color(0xFFFB923C);  // Orange

  // Mode Gelap
  static const Color backgroundDark = Color(0xFF0A1128); // Very Dark Navy
  static const Color surfaceDark = Color(0xFF162545);    // Navy Surface
  static const Color primaryDark = Color(0xFF00B4D8);    // Vivid Cyan for dark mode
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surfaceLight,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.blueGrey.shade800),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.blueGrey.shade600),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withAlpha(204), // 80% opacity for glassmorphism look
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(128), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(204),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        elevation: 10,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.primary,
        surface: AppColors.surfaceDark,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade200),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey.shade100),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade400),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark.withAlpha(178), // 70% opacity for glassmorphism in dark mode
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(26), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark.withAlpha(128),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(13)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        elevation: 10,
      ),
    );
  }
}

// Glassmorphism Card Decoration Helper
BoxDecoration glassDecoration({required BuildContext context, double opacity = 0.6, double blur = 15.0}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark 
        ? AppColors.surfaceDark.withOpacity(opacity) 
        : Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark 
          ? Colors.white.withOpacity(0.1) 
          : Colors.white.withOpacity(0.5),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: isDark 
            ? Colors.black.withOpacity(0.3) 
            : AppColors.primary.withOpacity(0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
