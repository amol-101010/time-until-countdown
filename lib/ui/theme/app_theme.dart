import 'package:flutter/material.dart';

/// Brand colors sampled from the app logo (assets/branding/logo_source.png):
/// deep navy background + a bright blue accent.
class BrandColors {
  const BrandColors._();

  static const navy = Color(0xFF0F1528);
  static const blue = Color(0xFF0C66DD);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: BrandColors.blue),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.blue,
        brightness: Brightness.dark,
        surface: BrandColors.navy,
      ),
      scaffoldBackgroundColor: BrandColors.navy,
      useMaterial3: true,
    );
  }
}
