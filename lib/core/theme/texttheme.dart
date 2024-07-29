import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final TextTheme textTheme = GoogleFonts.chakraPetchTextTheme(
  const TextTheme(
    displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  ),
);
