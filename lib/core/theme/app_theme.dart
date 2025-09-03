import 'package:flutter/material.dart';

// 1. Define the color palette
class AppColors {
  // Main Palette
  static const Color background = Color(0xFFFBF7F4); // Soft, warm off-white
  static const Color surface = Color(0xFFFFFFFF); // For cards
  static const Color primary =
      Color(0xFF954C2E); // A deep, warm brown for buttons/accents
  static const Color onPrimary =
      Color(0xFFFFFFFF); // Text on primary color buttons
  static const Color secondary =
      Color(0xFFEFE4D2); // Light beige for highlights

  // Text Palette
  static const Color textPrimary = Color(0xFF4B352A); // Dark brown for headings
  static const Color textSecondary =
      Color(0xFF7D6C62); // Lighter brown for body text
  static const Color textDisabled =
      Color(0xFFC2B280); // Muted for disabled states

  // Special Colors
  static const Color accent = Color(0xFFCA7842); // For "Most Popular" tag
  static const Color success = Color(0xFF5B8C5A);
}

// 2. Define the main theme
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily:
          'Poppins', // Make sure to add this font to your pubspec.yaml and assets

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: Colors.red,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 32),
        headlineSmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22), // For card titles
        titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18), // For section titles
        bodyLarge: TextStyle(
            color: AppColors.textSecondary, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(
            color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        labelLarge: TextStyle(
            color: AppColors.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold), // For button text
      ),

      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
