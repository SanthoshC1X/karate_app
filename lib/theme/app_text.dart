import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system — all text styles use Figtree.
/// Use these in every screen: never define inline TextStyle.
class AppText {
  AppText._();

  static TextStyle _f(double size, FontWeight weight, {Color? color, double? height}) =>
      GoogleFonts.figtree(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height ?? 1.4,
      );

  // ── Display / Page titles ─────────────────────────────────────────────────
  static TextStyle get display => _f(28, FontWeight.w800, height: 1.2);
  static TextStyle get h1      => _f(22, FontWeight.w700, height: 1.3);
  static TextStyle get h2      => _f(18, FontWeight.w700);
  static TextStyle get h3      => _f(16, FontWeight.w600);

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get body       => _f(15, FontWeight.w400, height: 1.6);
  static TextStyle get bodyMedium => _f(14, FontWeight.w500);
  static TextStyle get bodySmall  => _f(13, FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get bodyMuted  => bodySmall;

  // ── Labels & Captions ─────────────────────────────────────────────────────
  static TextStyle get label   => _f(13, FontWeight.w600);
  static TextStyle get caption => _f(12, FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get button  => _f(15, FontWeight.w600);

  // ── Backward-compatible aliases used across existing widgets ──────────────
  static TextStyle get r        => h3;
  static TextStyle get m        => bodyMedium;
  static TextStyle get s        => caption;
  static TextStyle get titleLg  => h1;
  static TextStyle get titleMd  => h2;
  static TextStyle get section  => h3.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get cta => _f(14, FontWeight.w700, color: AppColors.primary);
}
