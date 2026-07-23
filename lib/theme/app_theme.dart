import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryDark = Color(0xFF8B5CF6); // Violet
  static const Color primaryLight = Color(0xFF6D28D9);
  
  static const Color bgDark = Color(0xFF0F0F16); // Premium space/navy black
  static const Color bgLight = Color(0xFFF9FAFB); // Soft clean white
  
  static const Color cardDark = Color(0xFF1E1E2A); // Charcoal purple card
  static const Color cardLight = Colors.white;

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        secondary: const Color(0xFFEC4899), // Pink
        surface: bgDark,
        error: const Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSurface: const Color(0xFFE5E7EB),
      ),
      scaffoldBackgroundColor: bgDark,
      cardTheme: const CardThemeData(
        color: cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.bold),
          bodyLarge: const TextStyle(color: Color(0xFFF3F4F6)),
          bodyMedium: const TextStyle(color: Color(0xFFD1D5DB)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D2D3D),
        thickness: 1,
      ),
    );
  }

  /// Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryLight,
        secondary: const Color(0xFFDB2777),
        surface: bgLight,
        error: const Color(0xFFDC2626),
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1F2937),
      ),
      scaffoldBackgroundColor: bgLight,
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.bold),
          bodyLarge: const TextStyle(color: Color(0xFF111827)),
          bodyMedium: const TextStyle(color: Color(0xFF4B5563)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
      ),
    );
  }
}
