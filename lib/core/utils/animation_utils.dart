import 'package:flutter/animation.dart';

class AnimationUtils {
  static Animation<double> createFadeAnimation(
      AnimationController controller, {
        double begin = 0.0,
        double end = 1.0,
        Curve curve = Curves.easeInOut,
      }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  static Animation<Offset> createSlideAnimation(
      AnimationController controller, {
        Offset begin = const Offset(0, 1),
        Offset end = Offset.zero,
        Curve curve = Curves.easeOutCubic,
      }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}
