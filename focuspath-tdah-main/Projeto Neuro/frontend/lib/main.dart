import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool altoContraste = false;
  bool textoGrande = false;

  @override
  Widget build(BuildContext context) {
    return AppSettings(
      altoContraste: altoContraste,
      textoGrande: textoGrande,
      toggleAltoContraste: () =>
          setState(() => altoContraste = !altoContraste),
      toggleTextoGrande: () =>
          setState(() => textoGrande = !textoGrande),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: altoContraste
            ? ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.yellow,
          ),
          iconTheme: const IconThemeData(color: Colors.yellow),
          textTheme: TextTheme(
            bodyLarge: TextStyle(
                color: Colors.yellow,
                fontSize: textoGrande ? 20 : 16),
            bodyMedium: TextStyle(
                color: Colors.yellow,
                fontSize: textoGrande ? 18 : 14),
            titleLarge: TextStyle(
                color: Colors.yellow,
                fontSize: textoGrande ? 26 : 22,
                fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.all(Colors.yellow),
            checkColor: WidgetStateProperty.all(Colors.black),
          ),
        )
            : ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple),
          textTheme: TextTheme(
            bodyLarge:
            TextStyle(fontSize: textoGrande ? 20 : 16),
            bodyMedium:
            TextStyle(fontSize: textoGrande ? 18 : 14),
            titleLarge: TextStyle(
                fontSize: textoGrande ? 26 : 22,
                fontWeight: FontWeight.bold),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}