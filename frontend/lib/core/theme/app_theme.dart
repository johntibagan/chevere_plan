import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens del Figma Make (Guardados app diseño).
class AppColors {
  AppColors._();

  static const background = Color(0xFF0B0D15);
  static const surface = Color(0xFF141A24);
  static const surfaceElevated = Color(0xFF1C2333);
  static const sidebar = Color(0xFF0E1120);
  static const foreground = Color(0xFFF0F4FF);
  static const muted = Color(0xFF8E93AC);
  static const mutedDark = Color(0xFF5A607A);
  static const primary = Color(0xFFFFBB33);
  static const primarySoft = Color(0xFFFF8C42);
  static const accent = Color(0xFFFF5252);
  static const success = Color(0xFF00D68F);
  static const purple = Color(0xFF8B7FFF);
  static const border = Color(0x0FFFFFFF); // ~6% white

  static const catGastro = Color(0xFFFF8C42);
  static const catAloj = Color(0xFF8B7FFF);
  static const catNat = Color(0xFF00D68F);
  static const catCult = Color(0xFFE84393);
  static const catEnt = Color(0xFFFFBB33);
  static const catComp = Color(0xFF00C9A7);
  static const catEven = Color(0xFFFF5252);
  static const catServ = Color(0xFF4A90D9);
  static const catDeporte = Color(0xFF2ECC71);
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final body = GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.foreground,
      displayColor: AppColors.foreground,
    );
    final display = GoogleFonts.plusJakartaSansTextTheme(body);

    final scheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.background,
      secondary: AppColors.surfaceElevated,
      onSecondary: AppColors.foreground,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      error: AppColors.accent,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.foreground,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.border,
      outlineVariant: Color(0x14FFFFFF),
    );

    final radius = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      textTheme: display,
      primaryTextTheme: display,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.foreground,
        ),
        iconTheme: const IconThemeData(color: AppColors.muted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.mutedDark),
        labelStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        labelStyle: const TextStyle(color: AppColors.foreground, fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return AppColors.background;
          return AppColors.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.surfaceElevated;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.background),
        side: const BorderSide(color: AppColors.muted),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.sidebar,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.foreground),
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
        contentTextStyle: const TextStyle(color: AppColors.muted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.muted,
        textColor: AppColors.foreground,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  /// Gradiente del FAB / banners (Figma).
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primarySoft],
  );
}
