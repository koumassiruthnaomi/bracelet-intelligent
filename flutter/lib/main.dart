import 'package:flutter/material.dart';
import 'screens/pairing_screen.dart';
import 'theme.dart';

void main() {
  runApp(const BraceletApp());
}

class BraceletApp extends StatelessWidget {
  const BraceletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bracelet Intelligent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
      ),
      home: const PairingScreen(),
    );
  }
}
