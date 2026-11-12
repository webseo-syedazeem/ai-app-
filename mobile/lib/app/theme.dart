import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact Design System Tokens extracted from the AI Daily Helper HTML/PNG Package.
class AppColors {
  AppColors._();

  // Core palette
  static const Color navy = Color(0xFF12101B);
  static const Color navyChip = Color(0xFF151422);
  static const Color navyDeep = Color(0xFF0E0D18);
  static const Color navyLogo = Color(0xFF151942);

  static const Color indigo = Color(0xFF475BE0);
  static const Color indigoEm = Color(0xFF4D5BD9);
  static const Color indigoNav = Color(0xFF4353D8);
  static const Color indigoText = Color(0xFF3E4DC4);
  static const Color indigoPick = Color(0xFF4350C8);
  static const Color logoSwoosh = Color(0xFF667DFF);

  static const Color eyebrowPurple = Color(0xFF514FB5);
  static const Color mutedText = Color(0xFF585463);
  static const Color subText = Color(0xFF646070);
  static const Color sectionLabel = Color(0xFF605B6B);
  static const Color navMuted = Color(0xFF7D7E8D);

  // Surfaces & borders
  static const Color bgTop = Color(0xFFFBF7F1);
  static const Color bgMid = Color(0xFFF6F1EA);
  static const Color bgBottom = Color(0xFFF0EAE3);
  static const Color card = Color(0xFFFFFEFC);
  static const Color cardBorder = Color(0xFFE1D9D1);
  static const Color divider = Color(0xFFECE5DE);

  static const Color softLav = Color(0xFFEAECFF);
  static const Color softLavBorder = Color(0xFFCCD0FA);
  static const Color quoteLav = Color(0xFFEFEEFD);
  static const Color tileNeutral = Color(0xFFF1ECE6);
  static const Color tileBlue = Color(0xFFE0E3FE);
  static const Color tileEmerald = Color(0xFFD9F3E6);
  static const Color tileAmber = Color(0xFFFFEDC9);
  static const Color tileRose = Color(0xFFFFDFE6);
  static const Color tileViolet = Color(0xFFEBDFFF);
  static const Color chipBg = Color(0xFFF4F0EB);
  static const Color chipBorder = Color(0xFFDED6CE);
  static const Color fieldBorder = Color(0xFFDDD5CD);
  static const Color secondaryBtnBorder = Color(0xFFD0C8C0);
  static const Color barTrack = Color(0xFFE4E6F4);

  // Accents
  static const Color greenSuccess = Color(0xFF21966C);
  static const Color greenText = Color(0xFF1B815C);
  static const Color amberAccent = Color(0xFFC97808);
  static const Color roseAccent = Color(0xFFC43B52);
  static const Color violetAccent = Color(0xFF6B3FD6);
  static const Color starAmber = Color(0xFFF4AF44);
  static const Color avatarBg = Color(0xFFCFD6FF);
  static const Color avatarText = Color(0xFF1E2B8F);
  static const Color phasePillBg = Color(0xFFE8EAFF);
  static const Color phasePillText = Color(0xFF4754B4);

  // Dark voice screen
  static const Color voiceRadialCenter = Color(0xFF2B2D60);
  static const Color voiceRadialEdge = Color(0xFF141527);
  static const Color voiceStatusTop = Color(0xFF171829);
  static const Color voiceStopBg = Color(0xFFC6D0FF);
  static const Color voiceStopIcon = Color(0xFF1C2257);
  static const Color voiceActionBg = Color(0xFF353651);
  static const Color voiceSubtext = Color(0xFFC4C7E4);
  static const Color voiceMuted = Color(0xFFA4A8CA);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient screenWarm = LinearGradient(
    begin: Alignment(-0.5, -1.0),
    end: Alignment(0.5, 1.0),
    colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
    stops: [0.0, 0.62, 1.0],
  );

  static const LinearGradient softLavCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3F4FF), Color(0xFFE5E7FE)],
  );

  static const LinearGradient darkAiCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D1C31), Color(0xFF2B2C58)],
  );

  static const LinearGradient primaryBtn = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF28263A), Color(0xFF161522)],
  );

  static const LinearGradient accentIndigo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6475FA), Color(0xFF4959D8)],
  );

  static const LinearGradient voiceFloat = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1D31), Color(0xFF2E2F5D)],
  );

  static const LinearGradient progressFill = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4E5AD8), Color(0xFF7D8BFF)],
  );

  static const RadialGradient voiceDark = RadialGradient(
    center: Alignment(0.15, -0.15),
    radius: 1.0,
    colors: [AppColors.voiceRadialCenter, AppColors.voiceRadialEdge],
    stops: [0.0, 0.78],
  );
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x17181322),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0A181322),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> softCard = [
    BoxShadow(
      color: Color(0x1D4B5CE0),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x3812101B),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> voiceFloat = [
    BoxShadow(
      color: Color(0x421E1C36),
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> choose = [
    BoxShadow(
      color: Color(0x0B231D28),
      blurRadius: 14,
      offset: Offset(0, 5),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x10191720),
      blurRadius: 24,
      offset: Offset(0, -6),
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static TextStyle inter({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.navy,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );
    } catch (_) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );
    }
  }

  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgMid,
      colorScheme: const ColorScheme.light(
        primary: AppColors.indigo,
        secondary: AppColors.navy,
        surface: AppColors.card,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.navy,
      ),
      fontFamily: 'Inter',
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.indigo,
        selectionColor: Color(0x335365DF),
        selectionHandleColor: AppColors.indigo,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: inter(size: 12, weight: FontWeight.w600, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: inter(size: 12.5, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.indigo,
          textStyle: inter(size: 12.5, weight: FontWeight.w700, color: AppColors.indigo),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
