import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _customColor = Color(0xFF49149F);

const List<Color> _colorTheme = [
  _customColor,
  Colors.blue,
  Colors.indigo,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;

  AppTheme( this.isDarkMode, {this.selectedColor = 0})
    : assert(
        selectedColor >= 0 && selectedColor <= (_colorTheme.length - 1),
        'Los temas van desde el 0 hasta el ${_colorTheme.length - 1}',
      );

//   ThemeData getTheme() {
//   final baseColor = _colorTheme[selectedColor];

//   return ThemeData(
//     useMaterial3: true,
//     colorSchemeSeed: baseColor,
//     brightness: isDarkMode ? Brightness.dark : Brightness.light,
//     appBarTheme: const AppBarTheme(
//       centerTitle: true,
//       surfaceTintColor: Colors.transparent,
//     ),
//   );
// }

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorTheme[selectedColor],
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: _colorTheme[selectedColor],
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  static void setSystemUIOverlayStyle(
    bool isDarkMode, {
    int selectedColor = 0,
  }) {
    final themeBrithness = isDarkMode ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: themeBrithness,
        statusBarIconBrightness: themeBrithness,
        statusBarColor: _colorTheme[selectedColor],
        systemNavigationBarIconBrightness: themeBrithness,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }
}
