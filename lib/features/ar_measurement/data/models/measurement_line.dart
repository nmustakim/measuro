import 'measurement_point.dart';

class MeasurementLine {
  final int id;
  final MeasurementPoint startPoint;
  final MeasurementPoint endPoint;

  MeasurementLine({
    required this.id,
    required this.startPoint,
    required this.endPoint,
  });

  double get length => startPoint.position.distanceTo(endPoint.position);
}
