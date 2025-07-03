import 'package:vector_math/vector_math_64.dart' as vector;

class MeasurementPoint {
  final int id;
  final vector.Vector3 position;
  final vector.Vector2 screenPosition;

  MeasurementPoint({
    required this.id,
    required this.position,
    required this.screenPosition,
  });
}
