import 'package:flutter/material.dart';

/// Dark theme for the app.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  // Main background color for Scaffold and app
  scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
  cardColor: const Color.fromARGB(255, 40, 40, 40),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0,
    backgroundColor: Color.fromARGB(255, 30, 30, 30),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 25,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 30, 30, 30),
    selectedItemColor: Colors.grey,
    unselectedItemColor: Color.fromARGB(255, 80, 80, 80),
    showSelectedLabels: false,
    showUnselectedLabels: false,
  ),
  dividerColor: Colors.grey[800],
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.grey,
    selectionHandleColor: Colors.grey,
    selectionColor: Colors.grey
  ),
  switchTheme: SwitchThemeData(
    trackOutlineColor: WidgetStateColor.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? Colors.grey[600]!
          : Colors.grey[800]!;
    }),
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.grey[400]
          : Colors.grey[700],
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.grey[600]
          : Colors.grey[800],
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color.fromARGB(255, 40, 40, 40),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  // Add more as needed
);

/// Light theme for the app.
/// Uses ARGB colors for a soft, modern light look.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  // Main background color for Scaffold and app
  scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
  cardColor: Color.fromARGB(255, 245, 245, 245),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0,
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: 25,
    ),
    iconTheme: IconThemeData(color: Colors.black),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
    selectedItemColor: Colors.lightBlueAccent,
    unselectedItemColor: Color.fromARGB(255, 180, 180, 180),
    showSelectedLabels: false,
    showUnselectedLabels: false,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.lightBlue,
    selectionColor: Colors.lightBlueAccent,
    selectionHandleColor: Colors.lightBlue,
  ),
  dividerColor: Colors.grey,
  switchTheme: SwitchThemeData(
    trackOutlineColor: WidgetStateColor.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? Colors.lightBlueAccent
          : Colors.grey[300]!;
    }),
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.lightBlue
          : Colors.grey[400],
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.lightBlueAccent
          : Colors.grey[300],
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color.fromARGB(255, 245, 245, 245),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
);
