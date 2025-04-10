import 'package:flutter/material.dart';
import 'dart:math';

class CircleSelector extends StatefulWidget {
  @override
  _CircleSelectorState createState() => _CircleSelectorState();
}

class _CircleSelectorState extends State<CircleSelector> {
  double _totalRotation = 0.0; // 总旋转角度（度）
  double _currentValue = 0.0;

  double _lastAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _handlePanStart(details),
      onPanUpdate: (details) => _handlePanUpdate(details),
      onPanEnd: (details) => _handlePanEnd(),
      child: CustomPaint(
        size: Size(200, 200),
        painter: CirclePainter(_totalRotation, _currentValue),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final touchPosition = box.globalToLocal(details.globalPosition);
    _lastAngle = _calculateAngle(touchPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final touchPosition = box.globalToLocal(details.globalPosition);
    final currentAngle = _calculateAngle(touchPosition);
    final deltaAngle = currentAngle - _lastAngle;
    setState(() {
      _totalRotation += deltaAngle;
      _lastAngle = currentAngle;
      _currentValue = _totalRotation * (60 / 360); // 每360度±60
    });
  }

  void _handlePanEnd() {
    // 可选：重置初始位置
    _lastAngle = 0.0;
  }

  double _calculateAngle(Offset position) {
    final center = Offset(100, 100); // 圆心坐标
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final angleRadians = atan2(dy, dx);
    final angleDegrees = angleRadians * 180 / 3.141592653589793;
    return angleDegrees;
  }
}

class CirclePainter extends CustomPainter {
  final double rotation; // 总旋转角度（度）
  final double currentValue;

  CirclePainter(this.rotation, this.currentValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 90.0; // 圆环半径

    // 绘制圆环
    final ringPaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, ringPaint);

    // 绘制指针（指向当前角度）
    final pointerLength = radius * 0.8;
    final angleRad = rotation * (3.141592653589793 / 180); // 转换为弧度
    final pointerEndX = center.dx + pointerLength * cos(angleRad);
    final pointerEndY = center.dy + pointerLength * sin(angleRad);
    final pointerPaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 5;
    canvas.drawLine(center, Offset(pointerEndX, pointerEndY), pointerPaint);

    // 绘制数值
    final text = TextSpan(
      text: '${currentValue.toStringAsFixed(1)}',
      style: TextStyle(color: Colors.black, fontSize: 20),
    );
    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.currentValue != currentValue;
  }
}
