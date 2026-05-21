import 'package:flutter/material.dart';

class AppSettings extends InheritedWidget {
  final bool altoContraste;
  final bool textoGrande;
  final VoidCallback toggleAltoContraste;
  final VoidCallback toggleTextoGrande;

  const AppSettings({
    super.key,
    required this.altoContraste,
    required this.textoGrande,
    required this.toggleAltoContraste,
    required this.toggleTextoGrande,
    required super.child,
  });

  static AppSettings of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSettings>()!;
  }

  @override
  bool updateShouldNotify(AppSettings oldWidget) =>
      altoContraste != oldWidget.altoContraste ||
          textoGrande != oldWidget.textoGrande;
}