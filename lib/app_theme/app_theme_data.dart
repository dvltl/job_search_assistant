import 'package:flutter/material.dart';

class AppThemeData {
  static const Color _primaryColor = Color(0xFF04273D);
  static const Color _accentColor = Color(0xFF3E5C76);
  static const Color _errorColor = Color(0xFF4C2B36);
  static const Color _selectionColor = Color(0xFF748CAB);
  static const Color _backgroundColor = Color(0xFF202C39);

  static ThemeData _data = ThemeData.dark().copyWith(
    primaryColor: _primaryColor,
    accentColor: _accentColor,
    buttonColor: _accentColor,
    backgroundColor: _backgroundColor,
    cursorColor: _accentColor,
    errorColor: _errorColor,
    scaffoldBackgroundColor: _backgroundColor,
    buttonTheme: ThemeData
        .dark()
        .buttonTheme
        .copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      buttonColor: _accentColor,
    ),
    floatingActionButtonTheme:
        ThemeData.dark().floatingActionButtonTheme.copyWith(
          backgroundColor: _accentColor,
        ),
    inputDecorationTheme: ThemeData.dark().inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
          borderRadius: getBorderRadius(),
          borderSide: new BorderSide(width: 1.5)
      ),
    ),
    textSelectionColor: _selectionColor,
    textSelectionHandleColor: _accentColor,
  );

  static ThemeData getData() => _data;

  static BorderRadius getBorderRadius() => BorderRadius.circular(25.0);
}
