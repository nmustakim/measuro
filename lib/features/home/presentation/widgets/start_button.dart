import 'package:flutter/material.dart';
import '../../../ar_measurement/presentation/screens/ar_measurement_screen.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _navigateToAR(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 20),
            SizedBox(width: 8),
            Text('Start Measuring',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _navigateToAR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  ARMeasurementScreen()),
    );
  }
}
