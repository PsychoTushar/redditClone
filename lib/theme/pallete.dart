import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((
  _ref,
) {
  return ThemeNotifier();
});

class Pallete {
  // Colors
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(color: whiteColor),
    ),
    // 🎨 Global colors
    primaryColor: blueColor,

    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      background: blackColor,
      surface: greyColor,
      onPrimary: whiteColor,
      onBackground: whiteColor,
      onSurface: whiteColor,
    ),

    // 🎯 Text color (default everywhere)
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: whiteColor,
      displayColor: whiteColor,
    ),

    // 🎯 Button theme (modern)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: blueColor, // default button color
        foregroundColor: whiteColor, // text/icon color
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: drawerColor),
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(color: blackColor),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.red,
      secondary: Colors.redAccent,
      background: whiteColor,
      surface: whiteColor,
      onPrimary: whiteColor,
      onBackground: blackColor,
      onSurface: blackColor,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: whiteColor),
    primaryColor: redColor,
    // colorScheme: ThemeData.light().colorScheme.copyWith(background: whiteColor),
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _mode;
  ThemeNotifier({ThemeMode mode = ThemeMode.dark})
    : _mode = mode,
      super(Pallete.darkModeAppTheme) {
    getTheme();
  }
  //Getter for checking what is the current value of the mode i.e. the theme for the seich in the profile drawer.
  ThemeMode get mode => _mode;
  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == 'light') {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
      prefs.setString('theme', 'light');
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
    }
  }
}
