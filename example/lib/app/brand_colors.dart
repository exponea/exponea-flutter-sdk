import 'package:flutter/material.dart';

/// Bloomreach brand palette for the example app.
///
/// Mirrors the Android example app `ui/theme/Color.kt` token-for-token
/// (see ADR 2026-10-06-1400). Yellow is a fill colour only — never use it for
/// text, borders, labels or cursors on light surfaces.
abstract final class BrandColors {
  static const yellow = Color(0xFFFFD500);
  static const black = Color(0xFF111111);
  static const white = Color(0xFFFFFFFF);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFDDDDDD);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey600 = Color(0xFF666666);
  static const grey700 = Color(0xFF424242);
  static const red = Color(0xFFD32F2F);
  static const green = Color(0xFF2E7D32);
}

ThemeData buildExampleAppTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: BrandColors.yellow,
    onPrimary: BrandColors.black,
    secondary: BrandColors.black,
    onSecondary: BrandColors.white,
    surface: BrandColors.white,
    onSurface: BrandColors.black,
    error: BrandColors.red,
    onError: BrandColors.white,
  );

  const inputBorderRadius = BorderRadius.all(Radius.circular(4));
  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  const buttonTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: BrandColors.white,
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: BrandColors.grey600),
      floatingLabelStyle: TextStyle(color: BrandColors.grey600),
      border: OutlineInputBorder(borderRadius: inputBorderRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputBorderRadius,
        borderSide: BorderSide(color: BrandColors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputBorderRadius,
        borderSide: BorderSide(color: BrandColors.black, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: inputBorderRadius,
        borderSide: BorderSide(color: BrandColors.grey300),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: BrandColors.black,
      selectionColor: BrandColors.yellow.withOpacity(0.4),
      selectionHandleColor: BrandColors.yellow,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: BrandColors.yellow,
        foregroundColor: BrandColors.black,
        disabledBackgroundColor: BrandColors.yellow.withOpacity(0.5),
        disabledForegroundColor: BrandColors.grey600,
        textStyle: buttonTextStyle,
        shape: buttonShape,
        minimumSize: const Size.fromHeight(44),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BrandColors.black,
        side: const BorderSide(color: BrandColors.black),
        textStyle: buttonTextStyle,
        shape: buttonShape,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: BrandColors.yellow,
      linearTrackColor: Colors.transparent,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      indicatorColor: BrandColors.yellow,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BrandColors.black,
      foregroundColor: BrandColors.white,
    ),
  );
}
