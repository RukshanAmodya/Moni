import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoniTheme {
  // Color Palette from Apixer Concept
  static const Color sageGreen = Color(0xFF9CAF9A);
  static const Color sageGreenLight = Color(0xFFDCE3DC);
  static const Color background = Color(0xFFF4F6F4);
  static const Color cardBg = Colors.white;
  static const Color blackAccent = Color(0xFF111311);
  static const Color darkText = Color(0xFF1E201E);
  static const Color mutedText = Color(0xFF767A76);

  // Pastels for categories / accents
  static const Color pastelBlue = Color(0xFFB3C5E5);
  static const Color pastelPink = Color(0xFFE5B3C9);
  static const Color pastelPurple = Color(0xFFC7B3E5);
  static const Color pastelGreen = Color(0xFFB3E5BA);
  static const Color pastelOrange = Color(0xFFE5C4B3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: sageGreen,
      colorScheme: const ColorScheme.light(
        primary: sageGreen,
        secondary: blackAccent,
        surface: cardBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkText),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkText),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkText),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: mutedText),
          labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mutedText),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        space: 0,
        thickness: 0,
      ),
      tabBarTheme: const TabBarTheme(
        dividerColor: Colors.transparent,
        indicatorColor: sageGreen,
        labelColor: sageGreen,
        unselectedLabelColor: mutedText,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: sageGreen, width: 1.5),
        ),
      ),
    );
  }

  // Common premium shadows & borders
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get blackCardDecoration => BoxDecoration(
        color: blackAccent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: blackAccent.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );
}
