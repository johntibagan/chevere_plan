import 'package:flutter/material.dart';

/// Tokens semánticos Chevere Plan (oscuro + claro).
@immutable
class ChevereThemeColors extends ThemeExtension<ChevereThemeColors> {
  const ChevereThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.sidebar,
    required this.foreground,
    required this.muted,
    required this.mutedDark,
    required this.border,
    required this.outlineVariant,
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.success,
    required this.purple,
    required this.requiredMark,
    required this.scrim,
    required this.onImage,
    required this.onImageMuted,
    required this.catGastro,
    required this.catAloj,
    required this.catNat,
    required this.catCult,
    required this.catEnt,
    required this.catComp,
    required this.catEven,
    required this.catServ,
    required this.catDeporte,
    required this.coverLodging,
    required this.coverNature,
    required this.coverSport,
    required this.coverScrim,
    required this.badgeInstagram,
    required this.badgeTikTok,
    required this.badgeFacebook,
    required this.googleButtonBg,
    required this.googleButtonBorder,
    required this.googleButtonFg,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color sidebar;
  final Color foreground;
  final Color muted;
  final Color mutedDark;
  final Color border;
  final Color outlineVariant;
  final Color primary;
  final Color primarySoft;
  final Color onPrimary;
  final Color accent;
  final Color success;
  final Color purple;
  final Color requiredMark;
  final Color scrim;
  final Color onImage;
  final Color onImageMuted;
  final Color catGastro;
  final Color catAloj;
  final Color catNat;
  final Color catCult;
  final Color catEnt;
  final Color catComp;
  final Color catEven;
  final Color catServ;
  final Color catDeporte;
  final Color coverLodging;
  final Color coverNature;
  final Color coverSport;
  final Color coverScrim;
  final Color badgeInstagram;
  final Color badgeTikTok;
  final Color badgeFacebook;
  final Color googleButtonBg;
  final Color googleButtonBorder;
  final Color googleButtonFg;

  static const dark = ChevereThemeColors(
    background: Color(0xFF0B0D15),
    surface: Color(0xFF141A24),
    surfaceElevated: Color(0xFF1C2333),
    sidebar: Color(0xFF0E1120),
    foreground: Color(0xFFF0F4FF),
    muted: Color(0xFF8E93AC),
    mutedDark: Color(0xFF5A607A),
    border: Color(0x0FFFFFFF),
    outlineVariant: Color(0x14FFFFFF),
    primary: Color(0xFF3D8BFF),
    primarySoft: Color(0xFF33D6C8),
    onPrimary: Color(0xFF0B0D15),
    accent: Color(0xFFFF5252),
    success: Color(0xFF00D68F),
    purple: Color(0xFF8B7FFF),
    requiredMark: Color(0xFFFF8C00),
    scrim: Color(0x8A000000),
    onImage: Color(0xFFFFFFFF),
    onImageMuted: Color(0x8AFFFFFF),
    catGastro: Color(0xFFFF8C42),
    catAloj: Color(0xFF8B7FFF),
    catNat: Color(0xFF00D68F),
    catCult: Color(0xFFE84393),
    catEnt: Color(0xFFF2789F),
    catComp: Color(0xFF00C9A7),
    catEven: Color(0xFFFF5252),
    catServ: Color(0xFF4A90D9),
    catDeporte: Color(0xFF2ECC71),
    coverLodging: Color(0xFF6B74D6),
    coverNature: Color(0xFF1B8F6A),
    coverSport: Color(0xFF3D9B6E),
    coverScrim: Color(0x66000000),
    badgeInstagram: Color(0xFFE1306C),
    badgeTikTok: Color(0xFF69C9D0),
    badgeFacebook: Color(0xFF1877F2),
    googleButtonBg: Color(0xFF1A1A1A),
    googleButtonBorder: Color(0x00000000),
    googleButtonFg: Color(0xFFFFFFFF),
  );

  static const light = ChevereThemeColors(
    background: Color(0xFFF7F9FC),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEEF1F7),
    sidebar: Color(0xFFFFFFFF),
    foreground: Color(0xFF12141C),
    muted: Color(0xFF5C6178),
    mutedDark: Color(0xFF9096AC),
    border: Color(0x14000000),
    outlineVariant: Color(0x1A000000),
    primary: Color(0xFF2563EB),
    primarySoft: Color(0xFF0EA5B7),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFE0393E),
    success: Color(0xFF00A876),
    purple: Color(0xFF6C5CE7),
    requiredMark: Color(0xFFD9720A),
    scrim: Color(0x66000000),
    onImage: Color(0xFFFFFFFF),
    onImageMuted: Color(0x8AFFFFFF),
    catGastro: Color(0xFFE8752F),
    catAloj: Color(0xFF6C5CE7),
    catNat: Color(0xFF00A876),
    catCult: Color(0xFFD12E7A),
    catEnt: Color(0xFFD65A82),
    catComp: Color(0xFF00A88B),
    catEven: Color(0xFFE0393E),
    catServ: Color(0xFF3D77B8),
    catDeporte: Color(0xFF25A85D),
    coverLodging: Color(0xFF565EBF),
    coverNature: Color(0xFF177956),
    coverSport: Color(0xFF32805C),
    coverScrim: Color(0x4D000000),
    badgeInstagram: Color(0xFFE1306C),
    badgeTikTok: Color(0xFF3FA9B0),
    badgeFacebook: Color(0xFF1877F2),
    googleButtonBg: Color(0xFFFFFFFF),
    googleButtonBorder: Color(0x1F000000),
    googleButtonFg: Color(0xFF1A1A1A),
  );

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primarySoft],
      );

  @override
  ChevereThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? sidebar,
    Color? foreground,
    Color? muted,
    Color? mutedDark,
    Color? border,
    Color? outlineVariant,
    Color? primary,
    Color? primarySoft,
    Color? onPrimary,
    Color? accent,
    Color? success,
    Color? purple,
    Color? requiredMark,
    Color? scrim,
    Color? onImage,
    Color? onImageMuted,
    Color? catGastro,
    Color? catAloj,
    Color? catNat,
    Color? catCult,
    Color? catEnt,
    Color? catComp,
    Color? catEven,
    Color? catServ,
    Color? catDeporte,
    Color? coverLodging,
    Color? coverNature,
    Color? coverSport,
    Color? coverScrim,
    Color? badgeInstagram,
    Color? badgeTikTok,
    Color? badgeFacebook,
    Color? googleButtonBg,
    Color? googleButtonBorder,
    Color? googleButtonFg,
  }) {
    return ChevereThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      sidebar: sidebar ?? this.sidebar,
      foreground: foreground ?? this.foreground,
      muted: muted ?? this.muted,
      mutedDark: mutedDark ?? this.mutedDark,
      border: border ?? this.border,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      purple: purple ?? this.purple,
      requiredMark: requiredMark ?? this.requiredMark,
      scrim: scrim ?? this.scrim,
      onImage: onImage ?? this.onImage,
      onImageMuted: onImageMuted ?? this.onImageMuted,
      catGastro: catGastro ?? this.catGastro,
      catAloj: catAloj ?? this.catAloj,
      catNat: catNat ?? this.catNat,
      catCult: catCult ?? this.catCult,
      catEnt: catEnt ?? this.catEnt,
      catComp: catComp ?? this.catComp,
      catEven: catEven ?? this.catEven,
      catServ: catServ ?? this.catServ,
      catDeporte: catDeporte ?? this.catDeporte,
      coverLodging: coverLodging ?? this.coverLodging,
      coverNature: coverNature ?? this.coverNature,
      coverSport: coverSport ?? this.coverSport,
      coverScrim: coverScrim ?? this.coverScrim,
      badgeInstagram: badgeInstagram ?? this.badgeInstagram,
      badgeTikTok: badgeTikTok ?? this.badgeTikTok,
      badgeFacebook: badgeFacebook ?? this.badgeFacebook,
      googleButtonBg: googleButtonBg ?? this.googleButtonBg,
      googleButtonBorder: googleButtonBorder ?? this.googleButtonBorder,
      googleButtonFg: googleButtonFg ?? this.googleButtonFg,
    );
  }

  @override
  ChevereThemeColors lerp(ThemeExtension<ChevereThemeColors>? other, double t) {
    if (other is! ChevereThemeColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ChevereThemeColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      sidebar: l(sidebar, other.sidebar),
      foreground: l(foreground, other.foreground),
      muted: l(muted, other.muted),
      mutedDark: l(mutedDark, other.mutedDark),
      border: l(border, other.border),
      outlineVariant: l(outlineVariant, other.outlineVariant),
      primary: l(primary, other.primary),
      primarySoft: l(primarySoft, other.primarySoft),
      onPrimary: l(onPrimary, other.onPrimary),
      accent: l(accent, other.accent),
      success: l(success, other.success),
      purple: l(purple, other.purple),
      requiredMark: l(requiredMark, other.requiredMark),
      scrim: l(scrim, other.scrim),
      onImage: l(onImage, other.onImage),
      onImageMuted: l(onImageMuted, other.onImageMuted),
      catGastro: l(catGastro, other.catGastro),
      catAloj: l(catAloj, other.catAloj),
      catNat: l(catNat, other.catNat),
      catCult: l(catCult, other.catCult),
      catEnt: l(catEnt, other.catEnt),
      catComp: l(catComp, other.catComp),
      catEven: l(catEven, other.catEven),
      catServ: l(catServ, other.catServ),
      catDeporte: l(catDeporte, other.catDeporte),
      coverLodging: l(coverLodging, other.coverLodging),
      coverNature: l(coverNature, other.coverNature),
      coverSport: l(coverSport, other.coverSport),
      coverScrim: l(coverScrim, other.coverScrim),
      badgeInstagram: l(badgeInstagram, other.badgeInstagram),
      badgeTikTok: l(badgeTikTok, other.badgeTikTok),
      badgeFacebook: l(badgeFacebook, other.badgeFacebook),
      googleButtonBg: l(googleButtonBg, other.googleButtonBg),
      googleButtonBorder: l(googleButtonBorder, other.googleButtonBorder),
      googleButtonFg: l(googleButtonFg, other.googleButtonFg),
    );
  }
}

