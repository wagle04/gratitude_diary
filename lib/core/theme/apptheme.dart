import 'package:flutter/material.dart';
import 'package:gratitude_diary/core/theme/texttheme.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: textTheme,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: textTheme,
  );

  static const Color mainColor = Color(0xFF008080);
  static const Color secondaryColor = Color(0xFFB02045);

  static ColorScheme colorScheme = ColorScheme.fromSwatch(
    primarySwatch: createMaterialColor(mainColor),
    accentColor: mainColor,
    errorColor: Colors.red,
  );

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
