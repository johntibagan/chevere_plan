import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

/// Estilos de texto de producto. **Un solo lugar** para tamaños/pesos display.
/// Cuerpo general: `Theme.of(context).textTheme` (DM Sans vía [AppTheme]).
abstract final class AppTypography {
  AppTypography._();

  /// Título de tab / pantalla (22, Jakarta ExtraBold).
  static TextStyle tabTitle({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.foreground,
      );

  /// AppBar / diálogo / coming soon (18, Jakarta Bold).
  static TextStyle screenTitle({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.foreground,
      );

  /// Hero sobre foto (20, Jakarta ExtraBold).
  static TextStyle heroOnImage({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.onImage,
      );

  /// Nombre en card / ficha (16, Jakarta ExtraBold).
  static TextStyle cardTitle({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.foreground,
      );

  /// Valor numérico en stat card (20, Jakarta ExtraBold).
  static TextStyle statValue({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
      );

  /// Etiqueta de sección home (13, Jakarta ExtraBold).
  static TextStyle sectionLabel({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.foreground,
      );

  /// Subtítulo / secundario (12).
  static TextStyle bodySecondary({Color? color}) => TextStyle(
        fontSize: 12,
        color: color ?? AppColors.muted,
      );

  /// Meta terciaria (11).
  static TextStyle meta({Color? color}) => TextStyle(
        fontSize: 11,
        color: color ?? AppColors.muted,
      );

  /// Pill / chip pequeño (10, Bold).
  static TextStyle microBold({Color? color}) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.foreground,
      );

  /// Badge red social / micro (9, ExtraBold).
  static TextStyle badge({Color? color}) => TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.onImage,
      );

  /// Link primario subrayado (12).
  static TextStyle link({Color? color}) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: color ?? AppColors.primary,
      );

  /// Login / marketing claim (14).
  static TextStyle tagline({Color? color}) => TextStyle(
        fontSize: 14,
        height: 1.35,
        color: color ?? AppColors.muted,
      );

  /// Título login (28, Jakarta ExtraBold).
  static TextStyle loginTitle({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.foreground,
      );
}
