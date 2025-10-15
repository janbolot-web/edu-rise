import 'dart:math' as math;
import 'package:flutter/material.dart';

class RotatingBorderContainer extends StatefulWidget {
  const RotatingBorderContainer({super.key});

  @override
  State<RotatingBorderContainer> createState() =>
      _RotatingBorderContainerState();
}

class _RotatingBorderContainerState extends State<RotatingBorderContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // бесконечное плавное вращение
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const appPrimary = Color(0xFF2D5BE3);
    const appSecondary = Color(0xFF7AA8FF);

    return SizedBox(
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 2 * math.pi;

          return Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: SweepGradient(
                startAngle: 0,
                endAngle: 2 * math.pi,
                colors: [
                  Colors.transparent,
                  appPrimary.withOpacity(0.0),
                  appSecondary.withOpacity(0.8),
                  appPrimary.withOpacity(0.9),
                  appSecondary.withOpacity(0.8),
                  appPrimary.withOpacity(0.0),
                  Colors.transparent,
                ],
                stops: const [
                  0.0,
                  0.35,
                  0.45,
                  0.5,
                  0.55,
                  0.65,
                  1.0,
                ],
                transform: GradientRotation(angle),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: appSecondary.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/icons/pdf-icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Загрузка PDF...',
                      style: TextStyle(
                        color: appPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_top,
                            size: 14, color: appSecondary),
                        SizedBox(width: 4),
                        Text(
                          'Подождите немного...',
                          style: TextStyle(
                            color: appSecondary,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}
