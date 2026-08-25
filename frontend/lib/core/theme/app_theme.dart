import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_radius.dart';
import 'chevere_theme_colors.dart';

/// Acceso a tokens activos (sincronizado en [MaterialApp.builder]).
class AppColors {
  AppColors._();

  static ChevereThemeColors _palette = ChevereThemeColors.dark;

  /// Actualiza la paleta activa al cambiar tema (ver [CheverePlanApp]).
  static void bind(ChevereThemeColors palette) => _palette = palette;

  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get surfaceElevated => _palette.surfaceElevated;
  static Color get sidebar => _palette.sidebar;
  static Color get foreground => _palette.foreground;
  static Color get muted => _palette.muted;
  static Color get mutedDark => _palette.mutedDark;
  static Color get border => _palette.border;
  static Color get outlineVariant => _palette.outlineVariant;
  static Color get primary => _palette.primary;
  static Color get primarySoft => _palette.primarySoft;
  static Color get onPrimary => _palette.onPrimary;
  static Color get accent => _palette.accent;
  static Color get success => _palette.success;
  static Color get purple => _palette.purple;
  static Color get requiredMark => _palette.requiredMark;
  static Color get scrim => _palette.scrim;
  static Color get onImage => _palette.onImage;
  static Color get onImageMuted => _palette.onImageMuted;
  static Color get catGastro => _palette.catGastro;
  static Color get catAloj => _palette.catAloj;
  static Color get catNat => _palette.catNat;
  static Color get catCult => _palette.catCult;
  static Color get catEnt => _palette.catEnt;
  static Color get catComp => _palette.catComp;
  static Color get catEven => _palette.catEven;
  static Color get catServ => _palette.catServ;
  static Color get catDeporte => _palette.catDeporte;
  static Color get coverLodging => _palette.coverLodging;
  static Color get coverNature => _palette.coverNature;
  static Color get coverSport => _palette.coverSport;
  static Color get coverScrim => _palette.coverScrim;
  static Color get badgeInstagram => _palette.badgeInstagram;
  static Color get badgeTikTok => _palette.badgeTikTok;
  static Color get badgeFacebook => _palette.badgeFacebook;
  static Color get googleButtonBg => _palette.googleButtonBg;
  static Color get googleButtonBorder => _palette.googleButtonBorder;
  static Color get googleButtonFg => _palette.googleButtonFg;
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(ChevereThemeColors.dark, Brightness.dark);

  static ThemeData light() => _build(ChevereThemeColors.light, Brightness.light);

  static ThemeData _build(ChevereThemeColors c, Brightness brightness) {
    final body = (brightness == Brightness.dark
            ? GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme)
            : GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme))
        .apply(
      bodyColor: c.foreground,
      displayColor: c.foreground,
    );
    final display = GoogleFonts.plusJakartaSansTextTheme(body);

    final scheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            brightness: Brightness.dark,
            primary: c.primary,
            onPrimary: c.onPrimary,
            secondary: c.surfaceElevated,
            onSecondary: c.foreground,
            tertiary: c.accent,
            onTertiary: c.onImage,
            error: c.accent,
            onError: c.onImage,
            surface: c.surface,
            onSurface: c.foreground,
            onSurfaceVariant: c.muted,
            outline: c.border,
            outlineVariant: c.outlineVariant,
          )
        : ColorScheme.light(
            brightness: Brightness.light,
            primary: c.primary,
            onPrimary: c.onPrimary,
            secondary: c.surfaceElevated,
            onSecondary: c.foreground,
            tertiary: c.accent,
            onTertiary: c.onImage,
            error: c.accent,
            onError: c.onImage,
            surface: c.surface,
            onSurface: c.foreground,
            onSurfaceVariant: c.muted,
            outline: c.border,
            outlineVariant: c.outlineVariant,
          );

    final radius = AppRadius.lgAll;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      cardColor: c.surface,
      dividerColor: c.border,
      textTheme: display,
      primaryTextTheme: display,
      extensions: [c],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: c.background,
        foregroundColor: c.foreground,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: c.foreground,
        ),
        iconTheme: IconThemeData(color: c.muted),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: TextStyle(color: c.mutedDark),
        labelStyle: TextStyle(color: c.muted),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: c.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: c.foreground,
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceElevated,
        selectedColor: c.primary.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: c.foreground, fontSize: 12),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return c.onPrimary;
          return c.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return c.primary;
          return c.surfaceElevated;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return c.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        side: BorderSide(color: c.muted),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 6,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.sidebar,
        selectedItemColor: c.primary,
        unselectedItemColor: c.mutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceElevated,
        contentTextStyle: TextStyle(color: c.foreground),
        actionTextColor: c.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c.foreground,
        ),
        contentTextStyle: TextStyle(color: c.muted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.muted,
        textColor: c.foreground,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
    );
  }

  /// Gradiente de marca (CTA, FAB, banners).
  static LinearGradient primaryGradient(ChevereThemeColors c) =>
      c.primaryGradient;
}
