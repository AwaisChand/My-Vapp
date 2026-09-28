import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Customer dashboard brand palette (customer-portal-theme.css)
  static const Color primary = Color(0xFF782074);
  static const Color primaryMid = Color(0xFFA74ECE);
  static const Color primaryDark = Color(0xFF5A1858);
  static const Color accent = Color(0xFFD2A7FF);
  static const Color primarySoft = Color(0xFFFAF5FB);
  static const Color primaryGlow = Color(0x52782074); // rgba(120,32,116,0.32)

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardGradientEnd = Color(0xFFFCF8FF);
  static const Color inputBg = Color(0xFFFFFFFF);
  static const Color secondaryBg = Color(0xFFF1F5F9);
  static const Color border = Color(0x3D94A3B8); // rgba(148,163,184,0.24)

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);

  // Nav icon colors (match sidebar)
  static const Color navHome = Color(0xFFEF4444);
  static const Color navCashback = Color(0xFF38BDF8);
  static const Color navOffers = Color(0xFFF97316);
  static const Color navVape = Color(0xFFF97316);
  static const Color navProfile = Color(0xFFA74ECE);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFA74ECE), Color(0xFF782074)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradientHover = LinearGradient(
    colors: [Color(0xFFA74ECE), Color(0xFF5A1858)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient135 = LinearGradient(
    colors: [Color(0xF5A74ECE), Color(0xFA5A1858)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD2A7FF), Color(0xFFA74ECE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFCF8FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0x0F000000).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get brandShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.32),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get navActiveShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.32),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];

  // Legacy aliases
  static Color darkGrayColor = textMuted;
  static Color tealBlueColor = navCashback;
  static Color whiteColor = Colors.white;
  static Color darkColor = textPrimary;
  static Color mediumGrayColor = textMuted;
  static Color apricotColor = const Color(0xFFFFEDD5);
  static Color lightKhakiColor = primarySoft;
  static Color dimGrayColor = textSecondary;
  static Color slateBlueColor = primary;
  static Color ashGrayColor = textMuted;
  static Color royalPurpleColor = primary;
  static Color neutralGrayColor = const Color(0xFFE2E8F0);
  static Color tomatoRedColor = danger;
  static Color midGrayRedColor = textMuted;
  static Color accentPink = accent;
}
