import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Colors as specified in Gazeo design
  static const Color primaryPurple = Color(0xFF632FE1);
  static const Color accentCoral = Color(0xFFFF685F);
  static const Color backgroundLight = Color(0xFFFBFBFB);
  static const Color textDark = Color(0xFF2C2836);
  
  // Neutral & Surface Colors
  static const Color cardLight = Colors.white;
  static const Color pillBackground = Color(0xFFF1F0F7);
  static const Color textMuted = Color(0xFF8B8798);
  static const Color borderLight = Color(0xFFECEAF3);
  
  // Dark Theme Palette (as seen in Vibrant Flows screen)
  static const Color darkBackground = Color(0xFF151124);
  static const Color darkSurface = Color(0xFF211A36);
  static const Color darkCard = Color(0xFF2B2245);
  static const Color darkTextMuted = Color(0xFFA59EB8);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF632FE1), Color(0xFF8C52FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient proDiamondGradient = LinearGradient(
    colors: [Color(0xFF9042F7), Color(0xFF5D27E6), Color(0xFFFF685F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantFlowsGradient = LinearGradient(
    colors: [Color(0xFF3B1E78), Color(0xFF1B1435)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPurple,
        secondary: AppColors.accentCoral,
        surface: AppColors.backgroundLight,
        onSurface: AppColors.textDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        secondary: AppColors.accentCoral,
        surface: AppColors.darkSurface,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
