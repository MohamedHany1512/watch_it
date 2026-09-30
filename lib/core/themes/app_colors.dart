import 'package:flutter/material.dart';

/// The app is **dark-first**: the whole visual identity (glows, glass, contrast
/// ratios) is tuned for a deep background, so light mode is intentionally not
/// offered instead of shipping a washed-out, half-finished light theme.
abstract final class AppColors {
  const AppColors._();

  // ------------------------------------------------------------- surfaces ---
  /// Page background - the "rich dark" base of the whole design.
  static const Color background = Color(0xFF0F0F1E);

  /// Slightly lighter layer used for cards and sheets.
  static const Color surface = Color(0xFF16162B);

  /// Elevated surface (app bar, floating bars).
  static const Color surfaceElevated = Color(0xFF1C1C34);

  /// Used for skeleton placeholders and image fallbacks.
  static const Color surfaceMuted = Color(0xFF23233F);

  // ---------------------------------------------------------------- brand ---
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryLight = Color(0xFFA78BFF);
  static const Color accent = Color(0xFF22D3EE);
  static const Color accentWarm = Color(0xFFFF4D8D);

  /// Ambient glow blobs painted behind the content.
  static const Color glowPrimary = Color(0xFF7C5CFF);
  static const Color glowAccent = Color(0xFF22D3EE);
  static const Color glowWarm = Color(0xFFFF4D8D);

  // ---------------------------------------------------------------- glass ---
  /// Fill of a frosted surface.
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassFillStrong = Color(0x1FFFFFFF);

  /// Hairline border of a frosted surface - the thing that sells the "edge".
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBorderStrong = Color(0x38FFFFFF);

  // ----------------------------------------------------------------- text ---
  static const Color textPrimary = Color(0xFFF4F3FF);
  static const Color textSecondary = Color(0xFFA9A7C9);
  static const Color textTertiary = Color(0xFF6F6D91);

  // ----------------------------------------------------------------- misc ---
  static const Color youtubeRed = Color(0xFFFF2D55);
  static const Color error = Color(0xFFFF5470);
  static const Color success = Color(0xFF3DDC97);
  static const Color warning = Color(0xFFFFC542);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  /// Standard corner radius of a video card.
  static const double cardRadius = 20;

  /// Standard corner radius of a pill / floating bar.
  static const double pillRadius = 28;
}

