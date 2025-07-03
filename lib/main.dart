import 'package:flutter/material.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const ARMeasurementApp());
}

class ARMeasurementApp extends StatelessWidget {
  const ARMeasurementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Object Measurement',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home:  HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


