import 'package:flutter/material.dart';
import 'dart:math';

/// Упрощённый узел уровня, рендерит центральную вертикальную линию и
/// помещает сам узел по зигзагу — то слева, то справа.
class LessonNode extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;
  final int index;
  final int totalItems;
  final int lessonCount; // количество уроков в этом элементе
  final int completedLessons; // сколько уроков пройдено
  final int points; // очки за элемент
  final bool isExpanded;
  final VoidCallback? onTap;
  final GlobalKey? anchorKey;

  const LessonNode({
    super.key,
    this.isCompleted = false,
    this.isCurrent = false,
    required this.index,
    required this.totalItems,
    this.lessonCount = 5,
    this.completedLessons = 2,
    this.points = 100,
    this.isExpanded = false,
    this.onTap,
    this.anchorKey,
  });

  bool get isRightSide => index % 2 == 0;

  @override
  Widget build(BuildContext context) {
    const double height = 100; // расстояние между центрами узлов (уменьшено)
    final double nodeSize = isCurrent ? 70 : 70;

    // Восьмишаговая схема горизонтального смещения (от -1.0 до 1.0)
    // 0: center
    // 1: slight left
    // 2: strong left
    // 3: slight left
    // 4: center
    // 5: slight right
    // 6: strong right
    // 7: slight right
    final int mod = index % 8;
    double alignX;
    switch (mod) {
      case 0:
        alignX = 0.0;
        break;
      case 1:
        alignX = -0.35;
        break;
      case 2:
        alignX = -0.6;
        break;
      case 3:
        alignX = -0.35;
        break;
      case 4:
        alignX = 0.0;
        break;
      case 5:
        alignX = 0.35;
        break;
      case 6:
        alignX = 0.6;
        break;
      case 7:
        alignX = 0.35;
        break;
      default:
        alignX = 0.0;
    }

    // Центральная вертикальная линия
    // Positioned.fill(
    //   child: Align(
    //     alignment: Alignment.center,
    //     child: FractionallySizedBox(
    //       heightFactor: 1,
    //       widthFactor: 0.02,
    //       child: Container(color: Colors.grey.shade300),
    //     ),
    //   ),
    // ),

    // Узел, размещаем через Align с computed alignX
    // compute outer size for positioning (current node has extra ring)
    final double outerSizeForPosition = isCurrent
        ? nodeSize + 12 * 2
        : nodeSize;
    final double topPadding = max(0.0, (height - outerSizeForPosition) / 2);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          
          Positioned.fill(
            child: Align(
              alignment: Alignment(alignX, 0),
              child: Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: GestureDetector(
                  onTap: onTap,
                  child: _buildNode(nodeSize),
                ),
              ),
            ),
          ),
          // Номер индекса рядом с узлом
        ],
      ),
    );
  }

  // Контент модального окна, рендерится как overlay (не двигает содержимое)
  // Anchor key is optional; the parent can pass a GlobalKey to measure
  // the position of the node for overlay placement.

  Widget _buildNode(double size) {
    if (isCurrent) {
      // Для текущего элемента: прогресс-бордер из дуг + отступ 24px
      final outerSize = size + 12 * 2;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: outerSize,
            height: outerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                 
                // CustomPaint для рисования дуг-прогресса с градиентом
                CustomPaint(
                  size: Size(outerSize, outerSize),
                  painter: GradientProgressRingPainter(
                    lessonCount: lessonCount,
                    completedCount: completedLessons,
                    strokeWidth: 7,
                    radius: outerSize / 2,
                  ),
                ),
                // Сам элемент в центре
                
                Container(
                  key: anchorKey,
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/lesson_current.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // (overlay modal rendered in the parent Stack)
        ],
      );
    } else {
      // Для остальных элементов
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            key: anchorKey,
            width: size,
            height: size,
            child: isCompleted
                ? Image(image: AssetImage('assets/images/lesson_completed.png'))
                : Image(image: AssetImage('assets/images/lesson_locked.png')),
          ),
          // (overlay modal rendered in the parent Stack)
        ],
      );
    }
  }

  // bottom-sheet removed; modal is rendered as overlay in the parent Stack
}

/// CustomPainter для рисования прогресс-бордера из отдельных дуг с градиентом
class GradientProgressRingPainter extends CustomPainter {
  final int lessonCount; // всего уроков
  final int completedCount; // пройдено уроков
  final double strokeWidth;
  final double radius;

  GradientProgressRingPainter({
    required this.lessonCount,
    required this.completedCount,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Начальный угол (начинаем с верхней точки)
    double startAngle = -pi / 2;
    // Если только 1 урок — рисуем полный круг без зазоров
    if (lessonCount == 1) {
      // Плавный градиент для полного круга
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader =
            SweepGradient(
              colors: [
                const Color(0xFF4CAF50), // зелёный
                const Color(0xFF66BB6A), // светло-зелёный
                const Color(0xFF81C784), // ещё светлее
                const Color(0xFFA5D6A7), // бледно-зелёный
                const Color(
                  0xFF4CAF50,
                ), // обратно в зелёный (замыкаем окружность)
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ).createShader(
              Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
            )
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius - strokeWidth / 2, paint);
      return;
    }

    // Для нескольких уроков: рассчитываем фиксированный зазор в пикселях
    const double gapPx = 10.0;
    final double radiusUsed = radius - strokeWidth / 2;
    double gapAngle = gapPx / radiusUsed;

    // Защита от слишком больших зазоров
    if (gapAngle * lessonCount >= 2 * pi * 0.9) {
      gapAngle = (2 * pi) / lessonCount * 0.05;
    }

    final anglePerLesson = (2 * pi) / lessonCount;
    final arcAngle = anglePerLesson - gapAngle;

    // Плавный градиент для пройденных уроков (много цветовых точек)
    final List<Color> gradientColors = [
      const Color(0xFF4CAF50), // зелёный
      const Color(0xFF66BB6A), // светло-зелёный
      const Color(0xFF81C784), // светлее
      const Color(0xFFA5D6A7), // бледно-зелёный
      const Color.fromARGB(255, 159, 208, 161), // очень бледный зелёный
      const Color(0xFF81C784), // возвращаемся назад
      const Color(0xFF66BB6A), // ещё назад
      const Color(0xFF4CAF50), // обратно в основной зелёный
    ];

    for (int i = 0; i < lessonCount; i++) {
      final isCompleted = i < completedCount;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (isCompleted) {
        // Плавный градиент для пройденных дуг
        paint.shader = SweepGradient(
          colors: gradientColors,
          stops: const [0.0, 0.14, 0.28, 0.42, 0.5, 0.58, 0.72, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radiusUsed));
      } else {
        // Серый цвет для непройденных
        paint.color = Colors.grey.shade300;
      }

      final arcStart = startAngle + (i * anglePerLesson) + (gapAngle / 2);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radiusUsed),
        arcStart,
        arcAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
