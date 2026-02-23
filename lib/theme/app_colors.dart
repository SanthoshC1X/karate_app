import 'package:flutter/material.dart';

class AppColors {
  /* --------------------------------------------------------------------------
   * BLUE SCALE (Primary / Links / Focus / CTA)
   * ------------------------------------------------------------------------*/
  static const Color blue1  = Color(0xFFF5F9FF);
  static const Color blue2  = Color(0xFFEAF2FF);
  static const Color blue3  = Color(0xFFD6E6FF);
  static const Color blue4  = Color(0xFFBFD8FF);
  static const Color blue5  = Color(0xFF9FC2FF);
  static const Color blue6  = Color(0xFF7DAAFF);
  static const Color blue7  = Color(0xFF5B8CFF);
  static const Color blue8  = Color(0xFF3A6FE0); // Primary
  static const Color blue9  = Color(0xFF2554B5);
  static const Color blue10 = Color(0xFF1E3A8A);

  /* --------------------------------------------------------------------------
   * SKIN / SAND SCALE (Warmth / Cards / Highlights)
   * ------------------------------------------------------------------------*/
  static const Color skin1  = Color(0xFFFFFBF7);
  static const Color skin2  = Color(0xFFFFF4EA);
  static const Color skin3  = Color(0xFFFFE9D6);
  static const Color skin4  = Color(0xFFFFD9B8);
  static const Color skin5  = Color(0xFFFFC89A);
  static const Color skin6  = Color(0xFFF4B183);
  static const Color skin7  = Color(0xFFE09A6C);
  static const Color skin8  = Color(0xFFC98255);
  static const Color skin9  = Color(0xFF9E6344);
  static const Color skin10 = Color(0xFF7A4A33);

  /* --------------------------------------------------------------------------
   * WHITE / SURFACE SCALE (Layout & Elevation)
   * ------------------------------------------------------------------------*/
  static const Color white1  = Color(0xFFFFFFFF);
  static const Color white2  = Color(0xFFFAFAFA);
  static const Color white3  = Color(0xFFF5F6F8);
  static const Color white4  = Color(0xFFF0F2F5);
  static const Color white5  = Color(0xFFE5E7EB);
  static const Color white6  = Color(0xFFD1D5DB);
  static const Color white7  = Color(0xFFBFC5CE);
  static const Color white8  = Color(0xFF9CA3AF);
  static const Color white9  = Color(0xFF6B7280);
  static const Color white10 = Color(0xFF374151);

  /* --------------------------------------------------------------------------
   * TEXT SCALE (Hierarchy & Accessibility)
   * ------------------------------------------------------------------------*/
  static const Color text1  = Color(0xFF0F172A); // Primary
  static const Color text2  = Color(0xFF1F2937);
  static const Color text3  = Color(0xFF374151);
  static const Color text4  = Color(0xFF4B5563);
  static const Color text5  = Color(0xFF6B7280);
  static const Color text6  = Color(0xFF9CA3AF);
  static const Color text7  = Color(0xFFCBD5E1);
  static const Color text8  = Color(0xFFE5E7EB);
  static const Color text9  = Color(0xFFF1F5F9);
  static const Color text10 = Color(0xFFFFFFFF);

  /* --------------------------------------------------------------------------
   * STATUS COLORS (Calm, Non-Aggressive)
   * ------------------------------------------------------------------------*/
  // Success
  static const Color successLight = Color(0xFFE6F4EA);
  static const Color success = Color(0xFF4CAF73);
  static const Color successDark = Color(0xFF2F855A);

  // Warning
  static const Color warningLight = Color(0xFFFFF6E5);
  static const Color warning = Color(0xFFFFE4A1);
  static const Color warningDark = Color(0xFFB7791F);

  // Error
  static const Color errorLight = Color(0xFFFDECEC);
  static const Color error = Color(0xFFE05353);
  static const Color errorDark = Color(0xFFB83232);

  // Info
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF1E40AF);

  /* --------------------------------------------------------------------------
   * BORDERS / DIVIDERS / OVERLAYS
   * ------------------------------------------------------------------------*/
  static const Color borderLight = Color(0x14000000);
  static const Color border = Color(0x26000000);
  static const Color borderStrong = Color(0x40000000);

  static const Color overlayLight = Color(0x0A000000);
  static const Color overlay = Color(0x1A000000);
  static const Color overlayStrong = Color(0x33000000);

  /* --------------------------------------------------------------------------
   * UTILITY
   * ------------------------------------------------------------------------*/
  static const Color transparent = Colors.transparent;
  static const Color black54 = Color(0x8A000000);

  /* --------------------------------------------------------------------------
   * APP DEFAULT TOKENS (USE THESE EVERYWHERE)
   * ------------------------------------------------------------------------*/
  static const Color appBackground = Color.fromARGB(255, 255, 241, 220);
  static const Color appSurface = white1;
  static const Color cardBackground = skin1;
  static const Color inputBackground = white3;

  static const Color primary = blue8;
  static const Color primaryHover = blue9;
  static const Color primaryPressed = blue10;

  static const Color textPrimary = text2;
  static const Color textSecondary = text4;
  static const Color textDisabled = text6;
  static const Color onPrimary = text10;
  static const Color onDanger = text10;

  static const Color divider = borderLight;

  /* --------------------------------------------------------------------------
   * LEGACY ALIASES (BACKWARD COMPATIBILITY)
   * ------------------------------------------------------------------------*/
  static const Color background = appBackground;
  static const Color surface = appSurface;
  static const Color field = inputBackground;
  static const Color fieldDark = white4;

  static const Color primaryDark = primaryPressed;

  static const Color textHint = textDisabled;
  static const Color textOnDark = textPrimary;
  static const Color textOnDark30 = Color(0x4D1F2937);
  static const Color textOnDark38 = Color(0x611F2937);
  static const Color textOnDark54 = Color(0x8A1F2937);
  static const Color textOnDark70 = Color(0xB31F2937);

  static const Color borderLighter = divider;
  static const Color borderMuted = white7;

  static const Color warningDeep = warningDark;
  static const Color dangerDeep = errorDark;
  static const Color accentPurple = blue7;
}
