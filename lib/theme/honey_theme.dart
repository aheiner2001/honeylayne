import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central palette + typography for the Honey Layne storefront.
class HoneyColors {
  // Header (soft sunny yellow gradient).
  static const headerTop = Color(0xFFFDF1A8);
  static const headerBottom = Color(0xFFF8DE7E);
  static const heroPanel = Color(0xFFF6DD80);

  // Page backgrounds (warm blush).
  static const blush = Color(0xFFFCEBEA);
  static const blushDeep = Color(0xFFFBE3E2);
  static const cream = Color(0xFFFBF4E9);

  // Pinks.
  static const pink = Color(0xFFEFA0B0); // primary button / accents
  static const pinkDeep = Color(0xFFE7849B); // headings
  static const pinkSoft = Color(0xFFF3B9C5);
  static const logo = Color(0xFFE88AA0);

  // Text.
  static const text = Color(0xFF6E5B57);
  static const textSoft = Color(0xFF9B8884);
}

class HoneyTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: HoneyColors.blush,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HoneyColors.pink,
        primary: HoneyColors.pink,
        surface: HoneyColors.blush,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.cormorantGaramondTextTheme(base.textTheme).apply(
        bodyColor: HoneyColors.text,
        displayColor: HoneyColors.pinkDeep,
      ),
    );
  }

  // Flowing elegant script for the wordmark.
  static TextStyle logoFont({double size = 44, Color? color}) =>
      GoogleFonts.allura(
        fontSize: size,
        height: 1.0,
        color: color ?? HoneyColors.logo,
        fontWeight: FontWeight.w400,
      );

  // Bouncy hand-script for hero + section flourishes.
  static TextStyle script({double size = 56, Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.dancingScript(
        fontSize: size,
        height: 1.05,
        color: color ?? HoneyColors.pinkDeep,
        fontWeight: weight,
      );

  // Elegant serif for section titles + product names.
  static TextStyle serif({double size = 18, Color? color, FontWeight weight = FontWeight.w600, double spacing = 0}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        color: color ?? HoneyColors.pinkDeep,
        fontWeight: weight,
        letterSpacing: spacing,
      );

  // Clean sans for nav, buttons, prices, body labels.
  static TextStyle sans({double size = 14, Color? color, FontWeight weight = FontWeight.w500, double spacing = 0}) =>
      GoogleFonts.quicksand(
        fontSize: size,
        color: color ?? HoneyColors.text,
        fontWeight: weight,
        letterSpacing: spacing,
      );
}
