import 'package:consent_app/consent_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  final key = GlobalKey();
  runApp(MaterialApp(
      key: key,
      home: ConsentApp(
          pathToConsentDocument: "assets/consent.md",
          onAccept: () => print("Hello World"))));
}
