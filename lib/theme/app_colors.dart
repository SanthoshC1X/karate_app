import 'package:flutter/material.dart';

/// Single source of truth for every colour token used in the app.
/// Screens and widgets must ONLY reference these tokens — never raw hex literals.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF3A6FE0);
  static const Color primaryDark  = Color(0xFF2855C0);
  static const Color primaryLight = Color(0xFFEBF2FF);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background  = Color(0xFFF4F6F9); // page scaffold
  static const Color surface     = Color(0xFFFFFFFF); // cards / sheets
  static const Color surfaceTint = Color(0xFFF0F3F8); // grouped / subtle areas

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color border      = Color(0xFFE2E8F0); // card / divider borders
  static const Color borderInput = Color(0xFFCBD5E1); // input / dropdown idle border
  static const Color borderLight = Color(0xFFF1F5F9); // hairline dividers

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint      = Color(0xFF9CA3AF);
  static const Color textDisabled  = Color(0xFF9CA3AF);
  static const Color onPrimary     = Color(0xFFFFFFFF);
  static const Color textOnDark38  = Color(0x61FFFFFF);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error        = Color(0xFFDC2626);
  static const Color errorLight   = Color(0xFFFEF2F2);
  static const Color warning      = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info         = Color(0xFF0EA5E9);
  static const Color infoLight    = Color(0xFFE0F2FE);

  // ── Misc aliases kept for widget compatibility ────────────────────────────
  static const Color appBackground = background;
  static const Color appSurface    = surface;
  static const Color field         = Color(0xFFF8FAFC); // input fill
  static const Color fieldDark     = surfaceTint;
  static const Color accentPurple  = Color(0xFF7C3AED);
  static const Color divider       = borderLight;

  // legacy scale aliases (kept so existing widget refs compile)
  static const Color blue7  = Color(0xFF5B8CFF);
  static const Color blue8  = primary;
  static const Color blue9  = primaryDark;
  static const Color blue10 = Color(0xFF1E3A8A);
  static const Color white1 = surface;
  static const Color white3 = Color(0xFFF5F6F8);
  static const Color white4 = surfaceTint;
  static const Color white5 = Color(0xFFE5E7EB);
  static const Color white6 = Color(0xFFD1D5DB);
  static const Color white7 = Color(0xFFBFC5CE);
  static const Color white8 = textHint;
  static const Color white9 = textSecondary;
  static const Color text1  = textPrimary;
  static const Color text2  = Color(0xFF1F2937);
  static const Color text3  = Color(0xFF374151);
  static const Color text4  = textSecondary;
  static const Color text5  = Color(0xFF6B7280);
  static const Color text6  = textHint;
  static const Color text10 = onPrimary;
  static const Color successDark  = Color(0xFF15803D);
  static const Color errorDark    = Color(0xFFB91C1C);
  static const Color warningDark  = Color(0xFFB45309);
  static const Color infoDark     = Color(0xFF0369A1);
  static const Color primaryHover   = primaryDark;
  static const Color primaryPressed = Color(0xFF1E3A8A);
  static const Color cardBackground = Color(0xFFFFFBF7);
  static const Color inputBackground = field;
  static const Color onDanger         = onPrimary;
  static const Color textOnDark       = textPrimary;
  static const Color textOnDark30     = Color(0x4D1F2937);
  static const Color textOnDark54     = Color(0x8A1F2937);
  static const Color textOnDark70     = Color(0xB31F2937);
  static const Color borderLighter    = divider;
  static const Color borderMuted      = white7;
  static const Color borderStrong     = Color(0x40000000);
  static const Color overlayLight     = Color(0x0A000000);
  static const Color overlay          = Color(0x1A000000);
  static const Color overlayStrong    = Color(0x33000000);
  static const Color transparent      = Colors.transparent;
  static const Color black54          = Color(0x8A000000);
  static const Color warningDeep      = warningDark;
  static const Color dangerDeep       = errorDark;

  // skin scale (kept for belt badge)
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
}
