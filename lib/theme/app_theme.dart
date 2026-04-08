import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors extracted from designs (Light Mode)
  static const Color primary = Color(0xFF096973);
  static const Color onPrimary = Color(0xFFEAFCFF);
  static const Color primaryContainer = Color(0xFFA3EFFA);
  static const Color onPrimaryContainer = Color(0xFF005B63);
  static const Color secondary = Color(0xFF4A4BD7);
  static const Color onSecondary = Color(0xFFFBF7FF);
  static const Color secondaryContainer = Color(0xFFE1E0FF);
  static const Color onSecondaryContainer = Color(0xFF3B3CC9);
  static const Color tertiary = Color(0xFF006B60);
  static const Color onTertiary = Color(0xFFE2FFF8);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color onSurface = Color(0xFF05345C);
  static const Color surfaceVariant = Color(0xFFD2E4FF);
  static const Color onSurfaceVariant = Color(0xFF3D618C);
  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF05345C);
  static const Color outline = Color(0xFF5A7DA9);
  static const Color outlineVariant = Color(0xFF91B4E4);
  static const Color error = Color(0xFFA83836);
  static const Color onError = Color(0xFFFFF7F6);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD2E4FF);
  static const Color primaryFixedDim = Color(0xFF95E1EB);
  static const Color tertiaryContainer = Color(0xFF65FDE6);

  // Dark Mode Colors
  static const Color primaryDark = Color(0xFF80D4E0);
  static const Color onPrimaryDark = Color(0xFF00363D);
  static const Color primaryContainerDark = Color(0xFF004F58);
  static const Color onPrimaryContainerDark = Color(0xFFA3EFFA);
  static const Color secondaryDark = Color(0xFFBFC0FF);
  static const Color onSecondaryDark = Color(0xFF1E1D94);
  static const Color surfaceDark = Color(0xFF0B141E);
  static const Color onSurfaceDark = Color(0xFFE1E2E8);
  static const Color surfaceVariantDark = Color(0xFF42474E);
  static const Color onSurfaceVariantDark = Color(0xFFC2C7CF);
  static const Color backgroundDark = Color(0xFF0B141E);
  static const Color onBackgroundDark = Color(0xFFE1E2E8);

  // Spacing & Radius
  static const double radiusDefault = 16.0;
  static const double radiusLarge = 32.0;
  static const double radiusExtraLarge = 48.0;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark 
      ? ColorScheme.dark(
          primary: primaryDark,
          onPrimary: onPrimaryDark,
          primaryContainer: primaryContainerDark,
          onPrimaryContainer: onPrimaryContainerDark,
          secondary: secondaryDark,
          onSecondary: onSecondaryDark,
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          surfaceVariant: surfaceVariantDark,
          onSurfaceVariant: onSurfaceVariantDark,
          background: backgroundDark,
          onBackground: onBackgroundDark,
          outline: onSurfaceVariantDark,
          error: error,
          onError: onError,
        )
      : ColorScheme.light(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: onSecondaryContainer,
          tertiary: tertiary,
          onTertiary: onTertiary,
          surface: surface,
          onSurface: onSurface,
          surfaceVariant: surfaceVariant,
          onSurfaceVariant: onSurfaceVariant,
          background: background,
          onBackground: onBackground,
          outline: outline,
          error: error,
          onError: onError,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          letterSpacing: -1.0,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: scheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
