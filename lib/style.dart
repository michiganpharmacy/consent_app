import 'package:flutter/material.dart';

Color primaryColor = Color(0xff006254);
Color footerBackgroundColor = Color.fromARGB(255, 166, 166, 166);
Color paragraphTextColor = Color.fromARGB(230, 33, 37, 41);

TextStyle appBarTextStyle = TextStyle(fontFamily: "Roboto");


ThemeData primaryThemeData = ThemeData(
  primaryColor: primaryColor,
  fontFamily: 'Roboto',
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.normal),
    headline6: TextStyle(fontSize: 22.0, fontWeight: FontWeight.normal, color: paragraphTextColor),
    subtitle1: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal,  color: paragraphTextColor),
    bodyText1: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
    bodyText2: TextStyle(fontSize: 16.0, fontFamily: 'Roboto'),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: primaryColor,

      onPrimary: Colors.white,
      onSurface: Colors.grey,
      textStyle: TextStyle(fontFamily: "Roboto", fontSize: 18, fontWeight: FontWeight.normal)
    ),
  ),
);
