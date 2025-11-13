import 'package:flutter/material.dart';

const Color seedColor = Colors.teal;

final ColorScheme defaultLightColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
);

final ColorScheme defaultDarkColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.dark,
);

ThemeData getLightTheme(ColorScheme? dynamicScheme) {
  return ThemeData(
    colorScheme: dynamicScheme ?? defaultLightColorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(backgroundColor: ColorScheme.light().surface),
    cardTheme: CardThemeData(color: ColorScheme.light().surfaceContainerHigh),
  );
}

ThemeData getDarkTheme(ColorScheme? dynamicScheme) {
  return ThemeData(
    colorScheme: dynamicScheme ?? defaultDarkColorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(backgroundColor: ColorScheme.dark().surface),
    cardTheme: CardThemeData(color: ColorScheme.dark().surfaceContainerHigh),
  );
}
