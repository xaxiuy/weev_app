import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeevTypography {
  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, height: 1.25),
    displayMedium: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
    headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33),
    headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
    bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.5),
    bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.43),
    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43),
    labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33),
  );
}
