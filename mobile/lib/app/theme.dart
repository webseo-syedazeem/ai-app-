import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact Design System Tokens extracted from the AI Daily Helper HTML/PNG Package.
class AppColors {
  AppColors._();

  // Core palette
  static const Color navy = Color(0xFF191720);
  static const Color navyChip = Color(0xFF1C1B2A);
  static const Color navyDeep = Color(0xFF171622);
  static const Color navyLogo = Color(0xFF1C2048);

  static const Color indigo = Color(0xFF5365DF);
  static const Color indigoEm = Color(0xFF5965D6);
  static const Color indigoNav = Color(0xFF5363D6);
  static const Color indigoText = Color(0xFF5462CB);
  static const Color indigoPick = Color(0xFF515BC6);
  static const Color logoSwoosh = Color(0xFF7186FF);

  static const Color eyebrowPurple = Color(0xFF6864B7);
  static const Color mutedText = Color(0xFF797681);
  static const Color subText = Color(0xFF827D87);
  static const Color sectionLabel = Color(0xFF86818C);
  static const Color navMuted = Color(0xFFA0A1AE);

  // Surfaces & borders
  static const Color bgTop = Color(0xFFF9F5EF);
  static const Color bgMid = Color(0xFFF5F1EB);
  static const Color bgBottom = Color(0xFFF2ECE7);
  static const Color card = Color(0xFFFFFCF8);
  static const Color cardBorder = Color(0xFFE8E3E0);
  static const Color divider = Color(0xFFECE7E2);

  static const Color softLav = Color(0xFFE9E9FA);
  static const Color softLavBorder = Color(0xFFDFDFF5);
  static const Color quoteLav = Color(0xFFECEAFA);
  static const Color tileNeutral = Color(0xFFF1EDEB);
  static const Color tileBlue = Color(0xFFE9E7FD);
  static const Color chipBg = Color(0xFFF2EEEA);
  static const Color chipBorder = Color(0xFFE7E0DA);
  static const Color fieldBorder = Color(0xFFE6DFD9);
  static const Color secondaryBtnBorder = Color(0xFFD9D3D0);
  static const Color barTrack = Color(0xFFE8E9F3);

  // Accents
  static const Color greenSuccess = Color(0xFF4FAD8A);
  static const Color greenText = Color(0xFF429778);
  static const Color starAmber = Color(0xFFF6B759);
  static const Color avatarBg = Color(0xFFCBD2FF);
  static const Color avatarText = Color(0xFF29369C);
  static const Color phasePillBg = Color(0xFFEEEFFD);
  static const Color phasePillText = Color(0xFF6470B4);

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
    stops: [0.0, 0.65, 1.0],
  );

  static const LinearGradient voiceFloat = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF222134), Color(0xFF343260)],
  );

  static const LinearGradient progressFill = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF474DB0), Color(0xFF7A87EC)],
  );

  static const RadialGradient voiceDark = RadialGradient(
    center: Alignment(0.2, -0.1),
    radius: 0.95,
    colors: [AppColors.voiceRadialCenter, AppColors.voiceRadialEdge],
    stops: [0.0, 0.72],
  );
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0C352625),
      blurRadius: 25,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x21171622),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> voiceFloat = [
    BoxShadow(
      color: Color(0x38251F41),
      blurRadius: 30,
      offset: Offset(0, 15),
    ),
  ];

  static const List<BoxShadow> choose = [
    BoxShadow(
      color: Color(0x062D1E21),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x06281D1D),
      blurRadius: 18,
      offset: Offset(0, -5),
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
