import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../data/models/measurement_line.dart';
import '../../data/models/measurement_point.dart';

class ARMeasurementScreen extends StatefulWidget {
  const ARMeasurementScreen({super.key});

  @override
  State<ARMeasurementScreen> createState() => _ARMeasurementScreenState();
}

class _ARMeasurementScreenState extends State<ARMeasurementScreen>
    with TickerProviderStateMixin {
  ArCoreController? _arCoreController;
  final List<MeasurementPoint> _measurementPoints = [];
  final List<MeasurementLine> _measurementLines = [];
  bool _isPlacingPoint = false;
  String _currentDistance = '0.0 cm';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _arCoreController?.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildARView(),
          _buildTopBar(),
          _buildBottomControls(),
          if (_isPlacingPoint) _buildCrosshair(),
        ],
      ),
    );
  }

  Widget _buildARView() {
    return ArCoreView(
      onArCoreViewCreated: (controller) {
        _arCoreController = controller;
        _initializeARScene();
      },
      enableTapRecognizer: true,
    );
  }

  Widget _buildTopBar() {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildTopBarButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(56),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentDistance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              _buildTopBarButton(
                icon: Icons.clear,
                onPressed: _clearMeasurements,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(56),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomControls() {
    return SlideTransition(
      position: _slideAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInstructionText(),
                const SizedBox(height: 24),
                _buildMeasureButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(56),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _isPlacingPoint
            ? 'Tap to place measurement point'
            : 'Tap the measure button to start',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMeasureButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPlacingPoint ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: _toggleMeasuring,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isPlacingPoint ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isPlacingPoint ? Colors.red : Colors.blue)
                        .withAlpha(25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isPlacingPoint ? Icons.stop : Icons.straighten,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCrosshair() {
    return const Center(
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  void _initializeARScene() {
    _arCoreController?.onPlaneDetected = (plane) {
    };

    _arCoreController?.onNodeTap = (name) {
      if (_isPlacingPoint) {
        _placeMeasurementPoint();
      }
    };
  }

  void _toggleMeasuring() {
    setState(() {
      _isPlacingPoint = !_isPlacingPoint;
    });

    HapticFeedback.lightImpact();
  }

  void _placeMeasurementPoint() {
    final screenCenter = vector.Vector2(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    final point = MeasurementPoint(
      id: _measurementPoints.length,
      position: vector.Vector3(0, 0, -1),
      screenPosition: screenCenter,
    );

    setState(() {
      _measurementPoints.add(point);
    });

    if (_measurementPoints.length >= 2) {
      final lastTwoPoints = _measurementPoints.sublist(
        _measurementPoints.length - 2,
      );

      _createMeasurementLine(lastTwoPoints[0], lastTwoPoints[1]);
      _calculateDistance(lastTwoPoints[0], lastTwoPoints[1]);
    }

    _addPointToARScene(point);
    HapticFeedback.lightImpact();
  }

  void _createMeasurementLine(MeasurementPoint start, MeasurementPoint end) {
    final line = MeasurementLine(
      id: _measurementLines.length,
      startPoint: start,
      endPoint: end,
    );

    setState(() {
      _measurementLines.add(line);
    });

    _addLineToARScene(line);
  }

  void _calculateDistance(MeasurementPoint start, MeasurementPoint end) {
    final distance = start.position.distanceTo(end.position);
    final distanceInCm = distance * 100; // Convert to centimeters

    setState(() {
      _currentDistance = '${distanceInCm.toStringAsFixed(1)} cm';
    });
  }

  void _addPointToARScene(MeasurementPoint point) {
    final material = ArCoreMaterial(
      color: Colors.blue,
      metallic: 0.0,
      roughness: 0.4,
    );

    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.02,
    );

    final node = ArCoreNode(
      shape: sphere,
      position: point.position,
      name: 'point_${point.id}',
    );

    _arCoreController?.addArCoreNode(node);
  }

  void _addLineToARScene(MeasurementLine line) {
    // Create a cylinder between two points to represent the line
    final direction = line.endPoint.position - line.startPoint.position;
    final distance = direction.length;
    final center = line.startPoint.position + (direction * 0.5);

    final material = ArCoreMaterial(
      color: Colors.yellow,
      metallic: 0.0,
      roughness: 0.4,
    );

    final cylinder = ArCoreCylinder(
      materials: [material],
      radius: 0.002,
      height: distance,
    );

    final node = ArCoreNode(
      shape: cylinder,
      position: center,
      name: 'line_${line.id}',
    );

    _arCoreController?.addArCoreNode(node);
  }

  void _clearMeasurements() {
    setState(() {
      _measurementPoints.clear();
      _measurementLines.clear();
      _currentDistance = '0.0 cm';
      _isPlacingPoint = false;
    });

    // Clear AR nodes
    _arCoreController?.removeNode(nodeName: 'point_*');
    _arCoreController?.removeNode(nodeName: 'line_*');

    HapticFeedback.lightImpact();
  }
}