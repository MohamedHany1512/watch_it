import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// The single, dark-first [ThemeData] of the application.
///
/// Design language: deep background, luminous accents, frosted glass surfaces
/// and a confident type scale. See `AppColors` for the token palette.
abstract final class AppTheme {
  const AppTheme._();

  /// Bundled Google Font (Tajawal) - used for Latin *and* Arabic.
  static const String fontFamily = 'Tajawal';

  static ThemeData get dark => _build();

  static const SystemUiOverlayStyle systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// The app colour scheme, exposed so widgets can align to it.
  static const ColorScheme colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.background,
    secondary: AppColors.accent,
    onSecondary: AppColors.background,
    tertiary: AppColors.accentWarm,
    onTertiary: AppColors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceMuted,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppColors.textTertiary,
    outlineVariant: AppColors.glassBorder,
  );

  static ThemeData _build() {
    final TextTheme textTheme = _textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      // InkSparkle gives the premium ripple used across cards and bars.
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: systemOverlay,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassFill,
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary),
        border: _inputBorder(AppColors.glassBorder),
        enabledBorder: _inputBorder(AppColors.glassBorder),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.5),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryLight,
        selectionColor: Color(0x557C5CFF),
        selectionHandleColor: AppColors.primaryLight,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.pillRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: AppColors.glassBorderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.pillRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.surfaceMuted,
        circularTrackColor: AppColors.surfaceMuted,
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceMuted,
        thumbColor: AppColors.white,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.pillRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }



  /// Typography scale.
  ///
  /// Line heights are deliberately generous: Arabic glyphs have tall ascenders
  /// and deep descenders, and tight line heights clip them.
  static final TextTheme _textTheme = const TextTheme(
    displaySmall: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      height: 1.3,
      letterSpacing: -0.3,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.45,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.45,
      color: AppColors.textSecondary,
    ),
    bodyLarge: TextStyle(
      fontSize: 15.5,
      height: 1.55,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 13.5,
      height: 1.55,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.5,
      color: AppColors.textTertiary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: AppColors.textTertiary,
    ),
  );
}

