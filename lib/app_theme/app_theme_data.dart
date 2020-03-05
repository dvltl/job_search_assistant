import 'package:flutter/material.dart';

class AppThemeData {
  static const Color _defaultColor = Colors.blueAccent;
  static const Color _errorColor = Colors.deepOrangeAccent;
  static const Color _selectionColor = Colors.blueGrey;

  static ThemeData _data = ThemeData.dark().copyWith(
    accentColor: _defaultColor,
    buttonColor: _defaultColor,
    cursorColor: _defaultColor,
    errorColor: _errorColor,
    floatingActionButtonTheme:
        ThemeData.dark().floatingActionButtonTheme.copyWith(
              backgroundColor: _defaultColor,
            ),
    inputDecorationTheme: ThemeData.dark().inputDecorationTheme.copyWith(
          border: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(25.0),
              borderSide: new BorderSide()),
        ),
    textSelectionColor: _selectionColor,
    textSelectionHandleColor: _defaultColor,
  );

  static Color cancelColor() => _errorColor;

  static ThemeData getData() => _data;
}
