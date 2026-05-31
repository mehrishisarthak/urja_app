import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Light Mode Theme ---
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: Colors.green.shade700,       
    secondary: Colors.amber.shade600,    
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black87,
    error: Colors.redAccent.shade700,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF6F8F6), // Extremely soft green/gray hint
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    color: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // Slightly rounder for modern card UI
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.green.shade600, width: 2.0),
    ),
    labelStyle: TextStyle(color: Colors.grey.shade600),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

// --- Dark Mode Theme ---
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: Colors.green.shade400,       // Radiant eco-green for dark mode screens
    secondary: Colors.amber.shade400,     // Glowing coin/energy indicators
    surface: const Color(0xFF1A1C1A),     // Rich dark base with a subtle forest undertone
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    error: Colors.red.shade400,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: const Color(0xFF0F110F), // Deep carbon-slate
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF1A1C1A),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    color: const Color(0xFF1A1C1A),
    surfaceTintColor: const Color(0xFF1A1C1A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade400,
      foregroundColor: Colors.black,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF242624),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade800),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.green.shade400, width: 2.0),
    ),
    labelStyle: TextStyle(color: Colors.grey.shade400),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);