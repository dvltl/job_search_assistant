import 'package:flutter/material.dart';

class BeautifulInputDecoration extends InputDecoration {
  BeautifulInputDecoration(String label) : super(
      labelText: label,
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.0),
        borderSide: new BorderSide(),
      )
  );
}