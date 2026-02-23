import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  // Typography scale (Figtree): h1, h2, r, m, s
  static final TextStyle h1 = GoogleFonts.figtree(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static final TextStyle h2 = GoogleFonts.figtree(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static final TextStyle r = GoogleFonts.figtree(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle m = GoogleFonts.figtree(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static final TextStyle s = GoogleFonts.figtree(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // Backward-compatible aliases used in existing screens.
  static TextStyle titleLg = h1;
  static TextStyle titleMd = h2;
  static TextStyle section = r.copyWith(fontWeight: FontWeight.w700);

  static TextStyle body = m;
  static TextStyle bodyMuted = m.copyWith(
    color: AppColors.textSecondary,
    fontSize: 13,
  );
  static TextStyle caption = s;

  static final TextStyle cta = GoogleFonts.figtree(
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );
}
