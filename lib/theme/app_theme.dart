import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Light Mode Colors ─────────────────────────────────────────────
  // Primary: Dusty Rose
  static const Color primary            = Color(0xFFB07080);
  static const Color onPrimary          = Color(0xFFFFF5F0);
  static const Color primaryContainer   = Color(0xFFF2D4D4);
  static const Color onPrimaryContainer = Color(0xFF7A4050);

  // Secondary: Muted Lavender
  static const Color secondary              = Color(0xFF8E7FA8);
  static const Color onSecondary            = Color(0xFFF8F4FF);
  static const Color secondaryContainer     = Color(0xFFDDD8EE);
  static const Color onSecondaryContainer   = Color(0xFF5A4A72);

  // Tertiary: Sage Green
  static const Color tertiary           = Color(0xFF7A9E8E);
  static const Color onTertiary         = Color(0xFFEFF6F2);
  static const Color tertiaryContainer  = Color(0xFFB8D4C8);

  // Surfaces — warm parchment / linen / cream hierarchy (NO blue tints)
  static const Color surface                    = Color(0xFFFDF8F2);
  static const Color onSurface                  = Color(0xFF3D2B1F);
  static const Color surfaceVariant             = Color(0xFFDECCB8);
  static const Color onSurfaceVariant           = Color(0xFF7A6055);
  static const Color background                 = Color(0xFFFDF8F2);
  static const Color onBackground               = Color(0xFF3D2B1F);

  static const Color surfaceContainerLowest  = Color(0xFFFBF5EE);
  static const Color surfaceContainerLow     = Color(0xFFF7EFE5);
  static const Color surfaceContainer        = Color(0xFFF0E5D8);
  static const Color surfaceContainerHigh    = Color(0xFFE8D8C8);
  static const Color surfaceContainerHighest = Color(0xFFDECCB8);

  // Outlines & misc
  static const Color outline          = Color(0xFFB89880);
  static const Color outlineVariant   = Color(0xFFD4B89A);
  static const Color primaryFixedDim  = Color(0xFFC49090);

  // Error
  static const Color error   = Color(0xFFB05050);
  static const Color onError = Color(0xFFFFF2F0);

  // ── Dark Mode Colors ──────────────────────────────────────────────
  // Dark Primary: lighter dusty rose
  static const Color primaryDark            = Color(0xFFE8A8B0);
  static const Color onPrimaryDark          = Color(0xFF4A1525);
  static const Color primaryContainerDark   = Color(0xFF72404A);
  static const Color onPrimaryContainerDark = Color(0xFFF2D4D4);

  // Dark Secondary: lighter muted lavender
  static const Color secondaryDark          = Color(0xFFC4B8D8);
  static const Color onSecondaryDark        = Color(0xFF352545);

  // Dark Surfaces — warm dark-roast brown, not dark navy
  static const Color surfaceDark            = Color(0xFF1E1610);
  static const Color onSurfaceDark          = Color(0xFFEDE0D4);
  static const Color surfaceVariantDark     = Color(0xFF3D312A);
  static const Color onSurfaceVariantDark   = Color(0xFFC4A898);
  static const Color backgroundDark         = Color(0xFF1E1610);
  static const Color onBackgroundDark       = Color(0xFFEDE0D4);

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
          tertiaryContainer: tertiaryContainer,
          surface: surface,
          onSurface: onSurface,
          surfaceVariant: surfaceVariant,
          onSurfaceVariant: onSurfaceVariant,
          background: background,
          onBackground: onBackground,
          outline: outline,
          outlineVariant: outlineVariant,
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
